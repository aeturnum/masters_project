#!/usr/bin/elixir

defmodule Bibformat do
  def main(args \\ []) do
    args
    |> parse_args
    |> response
  end

  defp parse_args(args) do
    args
    |> OptionParser.parse(aliases: [f: :filename], switches: [filename: :string])
    |> elem(0)
    
  end

   defp response(options) do
    options
    |> get_filename
    |> open_file
    |> print_lines
  end

  defp open_file(m = %{filename: f}) do
    case File.stat(f) do
      {:ok, info} -> 
        m 
        |> Map.put(:info, {:ok, info})
        |> Map.put(:stream, File.stream!(f, [:read]))
      {:error, why} ->
        m 
        |> Map.put(:info, {:error, why})
        |> Map.put(:stream, :error)
    end
  end

  defp print_lines(%{info: {:ok, _}, stream: s}) do
    s
    |> Enum.map(fn line ->
      case String.trim(line) do
        "" -> :ok
        l -> 
          l = character_replace(l)
              
          IO.puts("   \\item #{l}\n") 
      end
      
    end)
  end

  # error cases
  defp print_lines(%{info: {:error, why}, filename: fname}) do
    IO.puts("Could not open filename \"#{fname}\": #{why}")
  end

  defp character_replace(line) do
    line
    |> String.replace("_", "\\_")
    |> String.replace("&", "\\&")
    |> String.replace("©", "\\copyright")
    |> String.replace("™", "\\texttrademark")
  end

  defp get_filename(options) do
    %{filename: options |> Keyword.get(:filename, "proposed_bibliography.list")}
  end
end

Bibformat.main(System.argv())