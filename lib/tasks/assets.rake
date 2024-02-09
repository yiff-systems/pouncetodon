# frozen_string_literal: true

namespace :assets do
  desc 'Generate static pages'
  task generate_static_pages: :environment do
    def render_static_page(action, dest:, **opts)
      renderer = Class.new(ApplicationController) do
        def current_user
          nil
        end
      end

      html = renderer.render(action, opts)
      File.write(dest, html)
    end

    render_static_page 'errors/500', layout: 'error', dest: Rails.public_path.join('assets', '500.html')
  end

  desc "Fetch mastodon-modern CSS"
  task fetch_modern_css: :environment do
    # workaround because maintainer of mastodon-modern does not like their code being on github
    require "faraday"

    base_url = "https://codeberg.org/Freeplay/Mastodon-Modern/raw/commit/%<commit>s/%<filename>s"
    commit = "7444eaef9edcf89f2f6c3c5586e0bb93f090fe1d"
    {
      "modern.css" => %w[
        app/javascript/styles/modern/modern.css
        app/javascript/flavours/glitch/styles/modern/modern.css
      ],
      "glitch-fixes.css" => %w[
        app/javascript/flavours/glitch/styles/modern/glitch-fixes.css
      ],
    }.each do |filename, destinations|
      url = format(base_url, commit:, filename:)

      puts "Fetching #{url}"
      response = Faraday.get(url)
      unless response.success?
        warn "not successful due to #{response.reason_phrase.inspect}, skipping"
        next
      end

      content = response.body.force_encoding("UTF-8")
      destinations.each do |destination|
        path = Rails.root.join(destination)
        puts "Writing #{destination}"
        File.open(destination, "w") do |f|
          f.puts content
        end
      end
    end
  end
end

if Rake::Task.task_defined?('assets:precompile')
  Rake::Task['assets:precompile'].enhance(["assets:fetch_modern_css"]) do
    Webpacker.manifest.refresh
    Rake::Task['assets:generate_static_pages'].invoke
  end
end
