(function(jQuery) {
	jQuery.fn.filesize = function(o)
	{
		return this.each(function() {
			new jQuery.filesize(this, o);
		});
	};

	jQuery.filesize = function (e, o)
	{
		this.options		  	= o || {};
		this.element		  	= jQuery(e);
        this.init();
	};

	jQuery.filesize.fn = jQuery.filesize.prototype = {
    filesize: '1.0'
  };

 	jQuery.filesize.fn.extend = jQuery.filesize.extend = jQuery.extend;

	jQuery.filesize.fn.extend({

		init: function() {
            var fileSize = this.element.text();
            if (!fileSize) {
                return;
            }
            var longFileSize = parseInt(fileSize);
            var _fileSize = '';
            var vals;
            if (longFileSize === 0) {
                //do nothing, so empty string will be sent
            } else if (longFileSize < 100) {
                _fileSize = '' + longFileSize + 'bytes';
            } else if (longFileSize < (1000 * 1000)) {
                longFileSize = longFileSize / 1000;
                longFileSize = '' + longFileSize;
                vals = longFileSize.split('.');
                _fileSize = vals[0] + '.' + vals[1].substring(0, 1) + 'KB';
            } else {
                longFileSize = longFileSize / (1000 * 1000);
                longFileSize = '' + longFileSize;
                vals = longFileSize.split('.');
                _fileSize = vals[0] + '.' + vals[1].substring(0, 1) + 'MB';
            }
            this.element.text(_fileSize);
		}

	 });
})(jQuery);

