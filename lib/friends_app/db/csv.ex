defmodule FriendsApp.DB.CSV do
  alias Mix.Shell.IO, as: Shell
  alias FriendsApp.CLI.Menu
  alias NimbleCSV.RFC4180, as: CSVParser

  def perform(chosen_item) do
    case chosen_item do
      %Menu{ id: :create, label: _ } -> create()
      %Menu{ id: :update, label: _ } -> Shell.info("read")
      %Menu{ id: :read, label: _ } -> read()
      %Menu{ id: :delete, label: _ } -> Shell.info("delete")
    end

    FriendsApp.CLI.Menu.Choice.start()
  end

  defp create() do
    collect_data()
    |> Map.values()
    |> wrap_in_list()
    |> CSVParser.dump_to_iodata()
    |> save_csv_file()

  end

  defp collect_data() do
    Shell.cmd("clear")

    %{
      name: prompt_message("Digite o nome:"),
      email: prompt_message("Digite o email: ")
    }
  end

  defp prompt_message(message) do
    Shell.prompt(message)
    |> String.trim()
  end

  defp wrap_in_list(list) do
    [list]
  end

  defp save_csv_file(data) do
    File.write!("#{File.cwd!}/friends.csv", data, [:append])
  end

  defp read do
    File.read!("#{File.cwd!}/friends.csv")
    |> CSVParser.parse_string(headers: false)
    |> Enum.map( fn [email, name] ->
      %{name: name, email: email}
    end)
    |> Scribe.console()

  end
end
