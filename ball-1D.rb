class Ball
  attr_accessor :x, :y, :radius

  def initialize(app, options = {})
    @mass = options[:mass] or 0.0
    @velocity = options[:velocity] or [0.0, 0.0]
    @x = options[:position][0]
    @y = options[:position][1]
    @radius = 10
    @eta = 0.85

    @app = app
    @app.fill options[:fill]
    @circle = @app.oval :top => @x, :left => @y, :radius => @radius
  end

  # Momentum = mass * velocity
  def move
    @x += @velocity[0] * @mass
    @y += @velocity[1] * @mass

    @circle.move @x, @y
  end

  def check_collisions(balls)
    collided_ball = balls.find do |ball|
      ball != self and hit?(ball)
    end
    if collided_ball
      collide
      collided_ball.collide
    elsif collided_with_wall?
      collide
    end
  end

  def collided_with_wall?
    @x <= 0 or @x >= @app.width - (@radius * 2)
  end

  def collide
    @velocity[0] *= @eta 
    @velocity[0] *= -1
    move
  end

  def hit?(ball)
    # If the length of the hypotenuse between two balls is
    # equal to or less than their combined widths then
    # they've collided
    origin_x = (ball.x - @x - @velocity[0]).abs
    origin_y = (ball.y - @y - @velocity[1]).abs
    hypotenuse = Math.sqrt((origin_x ** 2).to_f + (origin_y ** 2).to_f)
    hypotenuse <= ball.radius + @radius
  end
end

Shoes.app :width => 200, :height => 200 do
  background '#fff'
  balls = []
  radius = 20
  center_x = (width - radius) / 2
  center_y = (height - radius) / 2
  balls << Ball.new(self, :mass => 0.5,
                          :fill => '#ff0000',
                          :radius => radius,
                          :velocity => [4, 0.0],
                          :position => [center_x - 50, center_y])
  balls << Ball.new(self, :mass => 0.9,
                          :fill => '#0000ff',
                          :radius => radius,
                          :velocity => [-2, 0.0],
                          :position => [center_x + 50, center_y])

  @anim = animate 30 do
    balls.each do |ball|
      ball.check_collisions balls
    end

    balls.each do |ball|
      ball.move
    end
  end
end

