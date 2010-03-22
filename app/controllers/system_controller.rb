class SystemController < ApplicationController
  def show
    raise StandardError.new("Bad path") if params[:path].include?('..')
    send_file "#{MANGAR_DIR}/system/#{params[:path]}", :disposition => 'inline'
  end
end