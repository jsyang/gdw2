// Generated by CoffeeScript 1.4.0

define(function() {
  var Button;
  return Button = (function() {

    Button.prototype.x = 0;

    Button.prototype.y = 0;

    Button.prototype.w = 0;

    Button.prototype.h = 0;

    Button.prototype.shape = 'rect';

    Button.prototype.circleArc = 2 * Math.PI;

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
      if (this.color.opacity != null) {
        ac.globalAlpha = this.color.opacity;
        ac.globalCompositeOperation = 'lighter';
      }
      switch (this.shape) {
        case 'circle':
          ac.lineWidth = 2;
          ac.strokeStyle = '#111';
          ac.fillStyle = this.color[this.state];
          ac.beginPath();
          ac.arc(this.x + 16, this.y + 16, this.w, 0, Math.PI * 2);
          ac.fill();
          break;
        case 'rect':
          ac.lineWidth = 2;
          ac.strokeStyle = '#111';
          ac.fillStyle = this.color[this.state];
          ac.fillRect(this.x, this.y, this.w, this.h);
          ac.strokeRect(this.x, this.y, this.w, this.h);
          break;
        case 'image':
          ac.drawImage(atom.gfx[this.image], this.x, this.y);
      }
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
