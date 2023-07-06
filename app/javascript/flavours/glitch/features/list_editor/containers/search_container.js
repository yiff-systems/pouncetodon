import { injectIntl } from 'react-intl';

import { connect } from 'react-redux';

import { fetchListSuggestions, clearListSuggestions, changeListSuggestions } from '../../../actions/lists';
import Search from '../components/search';

const mapStateToProps = state => ({
  value: state.getIn(['listEditor', 'suggestions', 'value']),
});

const mapDispatchToProps = dispatch => ({
  onSubmit: value => dispatch(fetchListSuggestions(value)),
  onClear: () => dispatch(clearListSuggestions()),
  onChange: value => dispatch(changeListSuggestions(value)),
});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(Search));
