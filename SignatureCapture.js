'use strict';

var React = require('react');

var {
  requireNativeComponent,
  DeviceEventEmitter,
  View
} = require('react-native');

var Component = requireNativeComponent('RSSignatureView', null);

var styles = {
  signatureBox: {
    flex: 1
  },
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'stretch',
    backgroundColor: '#F5FCFF',
  }
};

var saveEvent, cancelEvent;

var SignatureCapture = React.createClass({
  propTypes: {
    pitchEnabled: React.PropTypes.bool
  },

  componentDidMount: function() {
    saveEvent = DeviceEventEmitter.addListener('onSaveEvent', this.props.onSaveEvent);
    cancelEvent = DeviceEventEmitter.addListener('onCancelEvent', this.props.onCancelEvent);
  },

  componentWillUnmount: function() {
    saveEvent.remove();
    cancelEvent.remove();
  },

  render: function() {
    return (
      <View style={styles.container}>
        <Component style={styles.signatureBox} />
      </View>
    )
  }
});

module.exports = SignatureCapture;
