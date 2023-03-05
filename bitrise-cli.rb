class BitriseCli < Formula
  desc "A command-line interface for Bitrise"
  homepage "https://github.com/jgallantgs/bitrise-cli"
  url "https://raw.githubusercontent.com/jgallantgs/bitrise-cli/main/bitrise-cli.zsh"
  sha256 "e1d067c346f76b6f35c6d2ed6c194e6e7d6c3d1f3e9d196b8a7b53116bce1cb3"

  def install
    bin.install "bitrise-cli.sh" => "bitrise"
  end

  test do
    system "#{bin}/bitrise", "-h"
  end
end
