// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require scriptaculous
//= require builder
//= require cropper/cropper
//= require_self

function endCropHandler(coords, dimensions) {
  $('x1').value = coords.x1;
  $('y1').value = coords.y1;
  $('x2').value = coords.x2;
  $('y2').value = coords.y2;
  $('width').value = dimensions.width;
  $('height').value = dimensions.height;
}

Event.observe(
  window,
  'load',
  function() {
    new Cropper.ImgWithPreview(
      'avatar',
      {
        minWidth: 200,
        minHeight: 200,
        ratioDim: { x: 50, y: 50 },
        displayOnInit: true,
        onEndCrop: endCropHandler,
        previewWrap: 'previewArea'
      }
    );
  }
);
