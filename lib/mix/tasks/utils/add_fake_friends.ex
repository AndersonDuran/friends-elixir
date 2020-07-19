defmodule Mix.Tasks.Utils.AddFakeFriends do
  use Mix.Task

  alias NimbleCSV.RFC4180, as: CSVParser
  alias Faker, as: Faker

  @shortdoc "Add fake friends to FriendsApp"
  def run(_) do
    Faker.start()

    create_friends([], 50)
    |> CSVParser.dump_to_iodata()
    |> save_csv_file()
  end

  defp create_friends(list, count) when count <= 1 do
    list ++ [random_friend()]
  end

  defp create_friends(list, count) do
    list ++ [random_friend()] ++ create_friends(list, count - 1)
  end

  defp random_friend do
    %{
      name: Faker.Person.PtBr.name(),
      email: Faker.Internet.email()
    }
    |> Map.values()
  end

  defp save_csv_file(data) do
    File.write!("#{File.cwd!}/friends.csv", data, [:append])
  end
end
