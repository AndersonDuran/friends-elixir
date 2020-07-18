defmodule FriendsApp.CLI.Main do
  alias Mix.Shell.IO, as: Shell

  def start_app do
    Shell.cmd("clear")
    welcome_message()
    Shell.prompt("Press any key...")
  end

  defp welcome_message do
    Shell.info("================= Friends App =================")
    Shell.info("                    WELCOME                    ")
    Shell.info("===============================================")
  end
end
