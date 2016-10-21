(function() {
  $(document).ready(function() {

  	// Scaleout gradient defined below
  	$('canvas').addClass('active');

  	// Canvas gradient animation taken from 
  	// https://codepen.io/smlsvnssn/pen/wzYoza
  	var ctx = $('canvas').get(0).getContext('2d');
		var c = 0,
			w = $(window).width(),
			h = $(window).height(),
			slideFactor = 300,
			circles = [];
			colours = [
				'255,120,0',
				'46,86,134',
				'131,207,255',
				'255,130,130',
				'48,101,181',
				'0, 85, 221',
				'237, 61, 69',
				'143, 70, 185',
				'81, 185, 224',
				'43, 222, 115',
				'0, 207, 181',
				'237, 156, 49',
			]

		for (var i = 0; i < colours.length; i++) {
			circles.push(
				new Circle((Math.random()*384)-64, (Math.random()*384)-64, (Math.random()*200)+100, colours[i])
			)
		}

		function drawCircle(x, y, r, c) {
			ctx.beginPath();
			var rad = ctx.createRadialGradient(x, y, 1, x, y, r);
			rad.addColorStop(0, 'rgba(' + c + ',.95)');
			rad.addColorStop(1, 'rgba(' + c + ',0)');
			ctx.fillStyle = rad;
			ctx.arc(x, y, r, 0, Math.PI * 2, false);
			ctx.fill();
		}

		function Circle(x, y, r, c) {
			this.x = x;
			this.y = y;
			this.r = r;
			this.c = c;
			this.targetX = 0;
			this.targetY = 0;
			this.targetR = 0;
			
			this.newTarget = function(){
				this.targetX = (Math.random()*384)-64;
				this.targetY = (Math.random()*384)-64;
				this.targetR = (Math.random()*200)+100;
			}
			this.slide = function(){
				this.x = this.x - ((this.x - this.targetX) / slideFactor);
				this.y = this.y - ((this.y - this.targetY) / slideFactor);
				this.r = this.r - ((this.r - this.targetR) / slideFactor);
				drawCircle(this.x, this.y, this.r, this.c);
			}
			
			this.newTarget();
		}


		(function animloop() {
			ctx.clearRect(0, 0, 256, 256);
			circles.forEach(function(circle){
				if (Math.random()>.99) {
					circle.newTarget();
				}
				circle.slide();
			})
			requestAnimationFrame(animloop);
		})();

  });
})();
  	