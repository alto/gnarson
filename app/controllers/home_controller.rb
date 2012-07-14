# require 'github_api'

class HomeController < ApplicationController

  def index
  end

  def login
    gh = Github.new(login: params[:login], password: params[:password])
    @events = gh.events.received(params[:login])
  end

end
