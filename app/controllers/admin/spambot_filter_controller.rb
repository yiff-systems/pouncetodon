# frozen_string_literal: true

module Admin
  class SpambotFilterController < BaseController
    def index
      @filter_logs = find_filter_logs
    end

    private

    FilterLog = Struct.new(:time, :reasons, :account) do
      @account_cache = {}

      def self.from_log_record(log_record)
        timestamp_s, reasons_s, account_id_s = log_record.split('$$')
        new(Time.at(timestamp_s.to_f).utc,
            reasons_s.split(',').map(&:to_sym),
            @account_cache[account_id_s.to_i] ||= begin
                                                    Account.find(account_id_s.to_i)
                                                  rescue ActiveRecord::RecordNotFound
                                                    account_id_s.to_i
                                                  end)
      end
    end

    def find_filter_logs
      Redis.current.lrange(SpambotValidator::REDIS_LOG_KEY, 0, -1).map do |raw_log_record|
        FilterLog.from_log_record(raw_log_record)
      end.sort_by(&:time).reverse
    end
  end
end
