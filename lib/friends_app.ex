defmodule FriendsApp do
  def hello do
    :world
  end

  def cur_environment do
    case Mix.env() do
      :prod -> "Production"
      :dev -> "Development"
      :test -> "Test"
    end
  end
end
