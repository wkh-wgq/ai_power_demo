class RecordsController < ApplicationController
  before_action :set_record, only: %i[ show edit update destroy ]

  # GET /records or /records.json
  def index
    @records = Record.all.order(created_at: :desc).page(params[:page])
  end

  # GET /records/1 or /records/1.json
  def show
  end

  # GET /records/new
  def new
    @record = Record.new(type: params[:type])
  end

  # GET /records/1/edit
  def edit
  end

  # POST /records or /records.json
  def create
    @record = Record.new(record_params)
    respond_to do |format|
      if @record.save
        format.html { redirect_to record_path(@record), notice: "创建成功！" }
        format.json { render :show, status: :created, location: @record }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /records/1 or /records/1.json
  def update
    respond_to do |format|
      if @record.update(record_params)
        format.html { redirect_to @record, notice: "更新成功！" }
        format.json { render :show, status: :ok, location: @record }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /records/1 or /records/1.json
  def destroy
    @record.destroy!

    respond_to do |format|
      format.html { redirect_to records_path, status: :see_other, notice: "删除成功！" }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_record
      @record = Record.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def record_params
      params.require(:record).permit(:label, :description, :type, :file_id)
    end
end