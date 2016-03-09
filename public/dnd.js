var DND = {
  initJoinForm: function() {
    $('form').on('submit', function(event) {
      data = $(this).serializeArray();
      jQuery.ajax( '/v2/dnd/join', {
        type: 'POST',
        data: data,
        success: function(response) {
          window.location = '/dnd/party';
          window.reload();
        },
        error: function(response, status) {
          $('.error-text').removeClass('hidden');
          text = response.responseText;
          if( !text || text === '' ) {
            text = 'looks like you\'re missing some fields!'
          }
          $('.error-text').text(text);
        }
      });
      event.preventDefault();
      event.stopImmediatePropagation();
      return false;
    });
  }
}