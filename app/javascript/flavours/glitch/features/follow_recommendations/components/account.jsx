import PropTypes from 'prop-types';

import { injectIntl, defineMessages } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { followAccount, unfollowAccount } from 'flavours/glitch/actions/accounts';
import { Avatar } from 'flavours/glitch/components/avatar';
import { DisplayName } from 'flavours/glitch/components/display_name';
import { IconButton } from 'flavours/glitch/components/icon_button';
import Permalink from 'flavours/glitch/components/permalink';
import { makeGetAccount } from 'flavours/glitch/selectors';

const messages = defineMessages({
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
});

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, props) => ({
    account: getAccount(state, props.id),
  });

  return mapStateToProps;
};

const getFirstSentence = str => {
  const arr = str.split(/(([.?!]+\s)|[．。？！\n•])/);

  return arr[0];
};

class Account extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    intl: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
  };

  handleFollow = () => {
    const { account, dispatch } = this.props;

    if (account.getIn(['relationship', 'following']) || account.getIn(['relationship', 'requested'])) {
      dispatch(unfollowAccount(account.get('id')));
    } else {
      dispatch(followAccount(account.get('id')));
    }
  };

  render () {
    const { account, intl } = this.props;

    let button;

    if (account.getIn(['relationship', 'following'])) {
      button = <IconButton icon='check' title={intl.formatMessage(messages.unfollow)} active onClick={this.handleFollow} />;
    } else {
      button = <IconButton icon='plus' title={intl.formatMessage(messages.follow)} onClick={this.handleFollow} />;
    }

    return (
      <div className='account follow-recommendations-account'>
        <div className='account__wrapper'>
          <Permalink className='account__display-name account__display-name--with-note' title={account.get('acct')} href={account.get('url')} to={`/@${account.get('acct')}`}>
            <div className='account__avatar-wrapper'><Avatar account={account} size={36} /></div>

            <DisplayName account={account} />

            <div className='account__note'>{getFirstSentence(account.get('note_plain'))}</div>
          </Permalink>

          <div className='account__relationship'>
            {button}
          </div>
        </div>
      </div>
    );
  }

}

export default connect(makeMapStateToProps)(injectIntl(Account));
