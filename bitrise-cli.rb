class BitriseCli < Formula
  desc "A command-line interface for Bitrise"
  homepage "https://github.com/jgallantgs/bitrise-cli"
  url "https://raw.githubusercontent.com/jgallantgs/bitrise-cli/main/bitrise-cli.sh"
  version "1.0.0" 
  sha256 "428fff4b59eeedd59356fea3676b08930e550dde40c05a47a02ab9d3852c7371"

  def install
    bin.install "bitrise-cli.sh" => "bitrise"
  end

  test do
    system "#{bin}/bitrise", "-h"
  end
end
