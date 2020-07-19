defmodule FriendsApp.DB.CSV do
  alias Mix.Shell.IO, as: Shell
  alias FriendsApp.CLI.Menu
  alias NimbleCSV.RFC4180, as: CSVParser
  alias FriendsApp.CLI.Friend

  def perform(chosen_item) do
    case chosen_item do
      %Menu{id: :create, label: _} -> create()
      %Menu{id: :read, label: _} -> read()
      %Menu{id: :update, label: _} -> update()
      %Menu{id: :delete, label: _} -> delete()
    end

    FriendsApp.CLI.Menu.Choice.start()
  end

  defp create() do
    collect_data()
    |> wrap_data_in_list()
    |> prepare_data()
    |> save_csv_file([:append])
  end

  defp wrap_data_in_list(list) do
    list
    |> Map.from_struct()
    |> Map.values()
    |> wrap_in_list()
  end

  defp prepare_data(list) do
    list
    |> CSVParser.dump_to_iodata()
  end

  defp collect_data() do
    Shell.cmd("clear")

    %Friend{
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

  defp save_csv_file(data, mode \\ []) do
    Application.fetch_env!(:friends_app, :csv_file)
    |> File.write!(data, mode)
  end

  defp read do
    get_friends_list_from_csv()
    |> show_friends()
  end

  defp get_friends_list_from_csv do
    read_csv_file()
    |> parse_csv_to_list()
    |> csv_list_to_friends()
  end

  defp read_csv_file do
    Application.fetch_env!(:friends_app, :csv_file)
    |> File.read!()
  end

  defp parse_csv_to_list(csv) do
    csv
    |> CSVParser.parse_string(skip_headers: false)
  end

  defp csv_list_to_friends(csv_list) do
    csv_list
    |> Enum.map(fn [email, name] ->
      %{name: name, email: email}
    end)
  end

  defp show_friends(friends_list) do
    friends_list
    |> Scribe.console()
  end

  defp delete() do
    Shell.cmd("clear")

    prompt_message("Digite o email da pessoa a ser deletada: ")
    |> search_friend_by_email()
    |> check_friend_was_found()
    |> confirm_delete()
    |> delete_and_save()
  end

  defp search_friend_by_email(email) do
    get_friends_list_from_csv()
    |> Enum.find(:not_found, fn list ->
      list.email == email
    end)
  end

  defp check_friend_was_found(friend) do
    case friend do
      :not_found ->
        Shell.cmd("clear")
        Shell.error("Amigo não encontrado!")
        Shell.prompt("Pressione qualquer tecla para continuar...")
        FriendsApp.CLI.Menu.Choice.start()

      _ ->
        friend
    end
  end

  defp confirm_delete(friend) do
    Shell.cmd("clear")
    Shell.info("Amigo encontrado!")

    show_friend(friend)

    case Shell.yes?("Deseja realmente apagar esse amigo?") do
      true -> friend
      false -> :error
    end
  end

  defp show_friend(friend) do
    friend
    |> Scribe.print(data: [{"Nome", :name}, {"Email", :email}])
  end

  defp delete_and_save(friend) do
    case friend do
      :error ->
        Shell.info("Amigo não será deletado!")
        Shell.prompt("Pressione qualquer tecla para continuar...")

      _ ->
        get_friends_list_from_csv()
        |> delete_friend_from_list(friend)
        |> friend_list_to_csv()
        |> prepare_data()
        |> save_csv_file()
    end
  end

  defp delete_friend_from_list(friends_list, friend) do
    friends_list
    |> Enum.reject(fn f -> f.email == friend.email end)
  end

  defp friend_list_to_csv(list) do
    list
    |> Enum.map(fn item ->
      [item.email, item.name]
    end)
  end

  defp update() do
    Shell.cmd("clear")

    prompt_message("Digite o email da pessoa a ser atualizada: ")
    |> search_friend_by_email()
    |> check_friend_was_found()
    |> confirm_update()
    |> do_update()
  end

  defp confirm_update(friend) do
    Shell.cmd("clear")
    Shell.info("Amigo encontrado!")

    show_friend(friend)

    case Shell.yes?("Deseja realmente atualizar esse amigo?") do
      true -> friend
      false -> :error
    end
  end

  defp do_update(friend) do
    Shell.cmd("clear")
    Shell.info("Digite os novos dados:")

    updated_friend = collect_data()

    get_friends_list_from_csv()
    |> delete_friend_from_list(friend)
    |> friend_list_to_csv()
    |> prepare_data()
    |> save_csv_file()

    updated_friend
    |> wrap_data_in_list()
    |> prepare_data()
    |> save_csv_file([:append])
  end

  Shell.info("Amigo atualizado com sucesso!")
end
