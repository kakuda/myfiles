/*
 * Bootstrap Image Gallery JS Example 2.9
 * https://github.com/blueimp/Bootstrap-Image-Gallery
 *
 * Copyright 2012, Sebastian Tschan
 * https://blueimp.net
 *
 * Licensed under the MIT license:
 * http://www.opensource.org/licenses/MIT
 */

/*jslint unparam: true */
/*global window, document, $ */

$(function () {
    'use strict';

    // Start slideshow button:
    $('#start-slideshow').button().click(function () {
        var options = $(this).data(),
            modal = $(options.target),
            data = modal.data('modal');
        if (data) {
            $.extend(data.options, options);
        } else {
            options = $.extend(modal.data(), options);
        }
        modal.find('.modal-slideshow').find('i')
            .removeClass('icon-play')
            .addClass('icon-pause');
        modal.modal(options);
    });

    // Toggle fullscreen button:
    $('#toggle-fullscreen').button().click(function () {
        var button = $(this),
            root = document.documentElement;
        if (!button.hasClass('active')) {
            $('#modal-gallery').addClass('modal-fullscreen');
            if (root.webkitRequestFullScreen) {
                root.webkitRequestFullScreen(
                    window.Element.ALLOW_KEYBOARD_INPUT
                );
            } else if (root.mozRequestFullScreen) {
                root.mozRequestFullScreen();
            }
        } else {
            $('#modal-gallery').removeClass('modal-fullscreen');
            (document.webkitCancelFullScreen ||
                document.mozCancelFullScreen ||
                $.noop).apply(document);
        }
    });

    // Load images via flickr for demonstration purposes:
    $.ajax({
        url: 'http://localhost:3000/api/songs',
        dataType: 'json',
    }).done(function (data) {
        var gallery = $('#gallery'),
            thumb, large;
        $.each(data, function (index, item) {
            thumb = item.image;
            large = thumb.replace('170x170', '600x600');
            $('<a data-gallery="gallery"/>')
                .append($('<img>').prop('src', thumb))
                .prop('href', large)
                .prop('title', item.title + ' / ' + item.artist)
                .attr('preview-url', item['preview-url'])
                .attr('song-id', item['song-id'])
                .attr('link', item.link)
                .attr('similars', item.similars.join(','))
                .appendTo(gallery);
        });
    });
});
