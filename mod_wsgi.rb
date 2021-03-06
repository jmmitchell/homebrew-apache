require 'formula'

class ModWsgi < Formula
  homepage 'http://modwsgi.readthedocs.org/en/latest/'
  url 'https://github.com/GrahamDumpleton/mod_wsgi/archive/3.5.tar.gz'
  sha1 '57552287ced75e5fd0b2b00fb186f963f9c4236b'

  head 'https://github.com/GrahamDumpleton/mod_wsgi.git'

  option 'with-brewed-httpd22', 'Use Homebrew Apache httpd 2.2'
  option 'with-brewed-httpd24', 'Use Homebrew Apache httpd 2.4'
  option 'with-brewed-python', 'Use Homebrew python'

  depends_on 'httpd22' if build.with? 'brewed-httpd22'
  depends_on 'httpd24' if build.with? 'brewed-httpd24'
  depends_on 'python' if build.with? 'brewed-python'

  def apache_apxs
    if build.with? 'brewed-httpd22'
      ['sbin', 'bin'].each do |dir|
        if File.exist?(location = "#{Formula['httpd22'].opt_prefix}/#{dir}/apxs")
          return location
        end
      end
    elsif build.with? 'brewed-httpd24'
      ['sbin', 'bin'].each do |dir|
        if File.exist?(location = "#{Formula['httpd24'].opt_prefix}/#{dir}/apxs")
          return location
        end
      end
    else
      '/usr/sbin/apxs'
    end
  end

  def apache_configdir
    if build.with? 'brewed-httpd22'
      "#{etc}/apache2/2.2"
    elsif build.with? 'brewed-httpd24'
      "#{etc}/apache2/2.4"
    else
      '/etc/apache2'
    end
  end

  def install
    args = "--prefix=#{prefix}", '--disable-framework'
    args << "--with-apxs=#{apache_apxs}"
    args << "--with-python=#{HOMEBREW_PREFIX}/bin/python" if build.with? 'brewed-python'
    system './configure', *args

    system 'make'

    libexec.install '.libs/mod_wsgi.so'
  end

  def caveats; <<-EOS.undent
    You must manually edit #{apache_configdir}/httpd.conf to include
      LoadModule wsgi_module #{libexec}/mod_wsgi.so

    NOTE: If you're _NOT_ using --with-brewed-httpd22 or --with-brewed-httpd24 and having
    installation problems relating to a missing `cc` compiler and `OSX#{MACOS_VERSION}.xctoolchain`,
    read the "Troubleshooting" section of https://github.com/Homebrew/homebrew-apache
    EOS
  end

end
