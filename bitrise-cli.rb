class BitriseCli < Formula
  desc "A command-line interface for Bitrise"
  homepage "https://github.com/jgallantgs/bitrise-cli"
  url "https://raw.githubusercontent.com/jgallantgs/bitrise-cli/main/bitrise-cli.zsh"
  sha256 "5234c5d54a6a3b8c63fa19989fcf364904835e507c742b830aaf1dafc8eee47c"

  def install
    bin.install "bitrise-cli.sh" => "bitrise"
  end

  test do
    system "#{bin}/bitrise", "-h"
  end
end
