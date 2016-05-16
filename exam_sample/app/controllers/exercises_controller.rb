class ExercisesController < ApplicationController

  def index
    if DemoQuestion.subjects.include?(params[:subject])
      @page_name = "exercise_#{params[:subject]}"
      subject = params[:subject]
      @component_data = {
        subject: subject
      }
      case subject
      when 'number'
        @component_data[:questions] = 
          (1..10).map do |i|
            num = rand(56887746371819585459)
            {
              content: num.to_s,
              answer: num.to_s
            }
          end
      when 'summons'
        format = "%0.2f"
        @component_data[:questions] =
          (1..10).map do |i|
            num = format % (rand * 103326588836)
            {
              content: num.to_s,
              answer: num.to_s
            }
          end
      else
      end


      render "mockup/page"
    else
      redirect_to root_path
    end
  end

end

