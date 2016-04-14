class QuestionRecordsController < ApplicationController
  before_action :authorization_user

  def index
    @question_records = current_user.question_records

    if params[:is_correct] != nil
      @question_records = @question_records.with_correct(params[:is_correct])
    end

    if params[:kind] != nil
      @question_records = @question_records.with_kind(params[:kind])
    end

    if params[:time] != nil
      time_query_hash = {
        "a_week"       => {:start_time => (Date.today - 6).to_time,:end_time => Time.now.to_time},
        "a_month"      => {:start_time => (Date.today - 30).to_time,:end_time => Time.now.to_time },
        "three_months" => {:start_time => (Date.today - 90).to_time,:end_time => Time.now.to_time }
      }
      query_str = time_query_hash[params["time"]]
      @question_records = @question_records.with_created_at(query_str)
    end
  end

  def destroy
    @question_record_single = current_user.question_records.find(params[:id])
    if @question_record_single.destroy
      @question_records = current_user.question_records.to_a - [@question_record_single]
      form_html = render_to_string :partial => 'record_index_tr',locals: { question_records: @question_records }
      render :json => {
        :status => 200,
        :body => form_html,
        :message => "success"
      }
    end
  end

  def batch_destroy
    temp = []
    params[:question_record_ids].each do |rid|
      @question_record_single = current_user.question_records.find(rid)
      temp.push(@question_record_single)
      @question_record_single.destroy
    end
    @question_records = current_user.question_records - temp
    form_html = render_to_string :partial => 'record_index_tr',locals: { question_records: @question_records }
    render :json => {
      :status => 200,
      :body => form_html,
      :message => "success"
    }
  end

end
