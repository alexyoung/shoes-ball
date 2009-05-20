require 'matrix'

class Ball
  attr_accessor :radius, :mass, :position, :velocity, :inverse_mass

  def initialize(app, options = {})
    @mass = options[:mass] or 0.0
    @velocity = Vector.[](options[:velocity][0], options[:velocity][1])
    @position = Vector.[](options[:position][0], options[:position][1])
    @radius = options[:radius] || 10
    @fixed = options[:fixed] || false
    @fill = options[:fill] || '#ff0000'
    @fill = '#000000' if @fixed
    @eta = 0.6
    @gravity = 1.0

    @inverse_mass = 1.0 / @mass
    @app = app
    @app.fill @fill
    draw
  end

  def draw
    @circle = @app.oval :top => @position[0], :left => @position[1], :radius => @radius
  end

  def remove
    @circle.hide
    @circle.remove
  end

  def fixed?
    @fixed
  end

  # Momentum = mass * velocity
  def update_momentum
    return if fixed?
    apply_gravity
    @position += @velocity * @mass
  end

  def update_sprite
    @circle.move @position[0], @position[1]
  end

  def move
    update_sprite
    update_momentum
  end

  def apply_gravity
    @velocity += Vector.[](0, @gravity)
  end

  def check_collisions
    wall_collisions
  end
  
  def bounce_off_wall
    @velocity = ((@velocity * -1) * @eta)
  end

  def wall_collisions
    if @position[0] <= 0
      @position = Vector.[](0, @position[1])
      bounce_off_wall
    end

    if @position[0] >= @app.width - (@radius * 2)
      @position = Vector.[](@app.width - (@radius * 2), @position[1])
      bounce_off_wall
    end

    if @position[1] <= 0
      @position = Vector.[](@position[0], 0)
      bounce_off_wall
    end

    if @position[1] >= @app.height - (@radius * 2)
      @position = Vector.[](@position[0], @app.height - (@radius * 2))
      bounce_off_wall
    end
  end
end

Shoes.app :width => 400, :height => 400 do
  background '#fff'
  balls = []

  def random_ball
    Ball.new(self, :mass => rand,
                   :fill => rgb(rand(255), rand(255), rand(255)),
                   :radius => 10,
                   :velocity => [rand - 1.0, rand - 1.0],
                   :fixed => false,
                   :position => [rand(width), rand(50)])

  end

  def load_balls
    balls = []
    (1..10).each do
      balls << random_ball
    end

    balls
  end

  def reload(balls)
    balls.each { |ball| ball.remove }
    balls = load_balls
  end

  balls = reload(balls)

  @anim = animate 30 do
    balls.each do |ball|
      ball.check_collisions
      ball.move
    end

    keypress do |k|
      case k
        when 'a':
          balls << random_ball 
        when 'r'
          balls = reload(balls)
      end
    end
  end
end

