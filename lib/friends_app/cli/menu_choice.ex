defmodule FriendsApp.CLI.MenuChoice do
  alias Mix.Shell.IO, as: Shell

  def start do
    Shell.cmd("clear")
    Shell.info("Escolha uma opção:")

    menu_itens = FriendsApp.CLI.MenuItens.all()

    #Sequencia de pipe operator
    #Cadeia de operações em cima do menu_items
    menu_itens
    |> Enum.map(&(&1.label))  #Dentro do map: função anônima, pegando o argumento 1 e chamando label
    |> display_options
  end

  defp display_options(options) do
    options
    |> Enum.with_index(1) #Enumerando os itens com indice e offset '1' [a:1, b:2]
    |> Enum.each(fn {option, index} ->
      Shell.info("#{index} - #{option}")
    end)
  end
end
