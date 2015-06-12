class PreferencesController < ApplicationController
  def index
    @preferences = Preference.all
  end

  def new
    @preference = Preference.new
  end

  def create
    @preference = Preference.new(params[:preference])
    if @preference.save
      redirect_to action: :index
    else
      render action: :new
    end
  end

  def edit
    @preference = Preference.find(params[:id])
  end

  def update
    @preference = Preference.find(params[:id])
    if @preference.update_attributes!(params[:preference])
      redirect_to action: :index
    else
      render action: :edit
    end
  end

  def destroy
    @preference = Preference.find(params[:id])
    @preference.destroy
    redirect_to action: :index
  end
end