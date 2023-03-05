class BitriseCli < Formula
  desc "A command-line interface for Bitrise"
  homepage "https://github.com/jgallantgs/bitrise-cli"
  url "https://raw.githubusercontent.com/jgallantgs/bitrise-cli/main/bitrise-cli.sh"
  version "1.0.0" 
  sha256 "97fb8f81650adb6d24ab20e884dabfb608bebc0b2f0e69e462ab8ba928821fb2"

  def install
    bin.install "bitrise-cli.sh" => "bitrise"
  end

  test do
    system "#{bin}/bitrise", "-h"
  end
end
