class QuestionsController < ApplicationController
  include QuestionBank::ApplicationHelper
  before_action :authorization_user
  def new_single_choice
    _new("single_choice")
  end

  def new_multi_choice
    _new("multi_choice")
  end

  def new_bool
    _new("bool")
  end

  def new_mapping
    _new("mapping")
  end

  def new_essay
    _new("essay")
  end

  def new_fill
    _new("fill")
  end

  def index
    params[:page] ||= 1
    @questions = QuestionBank::Question.page(params[:page]).per(6)
  end

  def create
    kind = params[:question][:kind]
    hash = send("question_#{kind}_params")
    @question = QuestionBank::Question.new(hash)
    if @question.save
      redirect_to questions_path
    else
      render "new_#{kind}"
    end
  end

  def edit
    @question = QuestionBank::Question.find(params[:id])
    @kind = @question.kind
    render "new_#{@kind}"
  end

  def update
    @question = QuestionBank::Question.find(params[:id])
    @kind = @question.kind
    hash = send("question_#{@kind}_params")
    if @question.update_attributes(hash)
      redirect_to "/questions"
    else
      render "new_#{@kind}"
    end
  end

  def destroy
    @question = QuestionBank::Question.find(params[:id])
    @question.destroy
    redirect_to "/questions"
  end

  def radom_question
    return QuestionBank::Question.skip(rand(0..QuestionBank::Question.count-1)).first
  end

  def do_question
    @question = radom_question()
  end

  def redo_question
    @question = QuestionBank::Question.find(params[:id])
  end

  def do_question_validation
    @question = QuestionBank::Question.find(params[:id])
    @record = @question.question_records.new(
      :user          => current_user,
      :answer        => params[:answer]
    )
    @record.save
    if @record.is_correct
      render :json => {
        :is_correct => true
      }
    else
      render :json => {
        :is_correct     => false,
        :correct_answer => @record.correct_answer
      }
    end
  end

  def search
    @type = params[:type]
    @kind = params[:kind]
    @min_level = params[:min_level].to_i
    @max_level = params[:max_level].to_i
    @per = params[:per].to_i
    @per = 5 if @per <= 0
    case @type
    when 'random'
      questions = QuestionBank::Question.where(kind: @kind, level: @min_level..@max_level)
      count = questions.count
      @questions = (0..count-1).sort_by{rand}.slice(0, @per).collect! do |i| questions.skip(i).first end
    when 'select'
      # 显示所有题目
      @questions = QuestionBank::Question.where(kind: @kind, level: @min_level..@max_level)
    else
      @questions = QuestionBank::Question.where(kind: @kind, level: @min_level..@max_level).page(params[:page]).per(@per)
    end
    render json: @questions.map{ |question|
      {
        id: question.id.to_s,
        content: question.content
      }
    }
  end

  private
  def _new(kind)
    @question = QuestionBank::Question.new(:kind => kind)
  end


  def question_bool_params
    params.require(:question).permit(:kind, :content, :bool_answer, :analysis, :level, :enabled)
  end

  def question_single_choice_params
    params.require(:question).permit(:kind, :content, :analysis, :level, :enabled, :choices => [], :choice_answer_indexs => [])
  end

  def question_multi_choice_params
    params.require(:question).permit(:kind, :content, :analysis, :level, :enabled, :choices => [], :choice_answer_indexs => [])
  end

  def question_fill_params
    params.require(:question).permit(:kind, :content, :analysis, :level, :enabled, :fill_answer => [])
  end

  def question_mapping_params
    new_mapping_answer = []
    params[:question][:mapping_answer].each { |key,value| new_mapping_answer[key.to_i] = value}
    hash = params.require(:question).permit(:kind, :content, :analysis, :level, :enabled)
    hash[:mapping_answer] = new_mapping_answer
    hash
  end

  def question_essay_params
    params.require(:question).permit(:kind, :content, :analysis, :essay_answer, :level, :enabled)
  end
end
