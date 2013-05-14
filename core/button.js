
define(function() {
  var Button;
  return Button = (function() {

    Button.prototype.x = 0;

    Button.prototype.y = 0;

    Button.prototype.w = 0;

    Button.prototype.h = 0;

    Button.prototype.containsPoint = function(x, y) {
      return ((this.x <= x && x <= this.x + this.w)) && ((this.y <= y && y <= this.y + this.h));
    };

    Button.prototype.state = 'up';

    Button.prototype.color = {
      pressed: '#b00',
      up: '#f00'
    };

    Button.prototype.draw = function() {
      var ac;
      ac = atom.context;
      ac.lineWidth = 2;
      ac.strokeStyle = '#111';
      ac.fillStyle = this.color[this.state];
      if (this.color.opacity != null) {
        ac.globalAlpha = this.color.opacity;
        ac.globalCompositeOperation = 'lighter';
      }
      ac.fillRect(this.x, this.y, this.w, this.h);
      ac.strokeRect(this.x, this.y, this.w, this.h);
      if (this.color.opacity != null) {
        ac.globalAlpha = 1;
        return ac.globalCompositeOperation = 'source-over';
      }
    };

    function Button(params) {
      var k, v;
      for (k in params) {
        v = params[k];
        this[k] = v;
      }
    }

    return Button;

  })();
});

// Generated by CoffeeScript 1.5.0-pre
