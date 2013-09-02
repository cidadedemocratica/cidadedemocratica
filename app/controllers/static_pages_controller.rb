class StaticPagesController < ApplicationController
  caches_action :show, :expires_in => 5.minutes, :cache_path => Proc.new { |c| c.params }, :layout => false

  def show
    render "static_pages/#{params[:name]}"
  end
end
