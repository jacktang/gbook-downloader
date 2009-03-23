require File.dirname(__FILE__) + '/spec_helper'

describe GBookDownloader::Proxies::RosinstrumentProvider  do 

  before do 
    @rosin = GBookDownloader::Proxies::RosinstrumentProvider.new
  end

  it 'should return nil if no input content' do
    proxies = @rosin.find_proxy_instances(nil)
    proxies.should be_nil
  end

  it 'should return one proxy instance' do 
    rss = <<-eorss
<?xml version="1.0" encoding="UTF-8"?>

<rss version="2.0"
 xmlns:blogChannel="http://backend.userland.com/blogChannelModule"
 xmlns:atom="http://www.w3.org/2005/Atom"
>

<channel>
<title>Rosinstrument.com: Proxy List Feed</title>
<link>http://rosinstrument.com/proxy/</link>
<description>Rosinstrument.com: Proxy List Feed, Thu, 19 Mar 2009 05:54:32 GMT</description>
<language>en</language>
<copyright>Free</copyright>
<pubDate>Thu, 19 Mar 2009 05:54:32 GMT</pubDate>

<lastBuildDate>Thu, 19 Mar 2009 05:54:32 GMT</lastBuildDate>
<docs>http://rosinstrument.com/proxy/</docs>
<managingEditor>support@rosinstrument.com (Support)</managingEditor>
<webMaster>support@rosinstrument.com (Support)</webMaster>
<atom:link href="http://rosinstrument.com/proxy/l100.xml" rel="self" type="application/rss+xml"/>

<image>
<title>Rosinstrument.com: Proxy List Feed</title>
<url>http://rosinstrument.com/img/favicon.gif</url>
<link>http://rosinstrument.com/proxy/</link>

<width>35</width>
<height>13</height>
<description>Rosinstrument.com: Proxy List Feed, Thu, 19 Mar 2009 05:54:32 GMT</description>
</image>

<item>

<title>201.89.84.67:80</title>
<link>http://rosinstrument.com/cgi-bin/shdb.pl?key=201.89.84.67:80</link>
<description>5 Kb/s, &#x3C;img src=&#x27;http://rosinstrument.com/img/fl/png/br.png&#x27; width=&#x27;16&#x27; 
height=&#x27;11&#x27; alt=&#x27;br&#x27; border=&#x27;0&#x27;&#x3E; br</description>

<guid isPermaLink="true">http://rosinstrument.com/cgi-bin/shdb.pl?key=201.89.84.67:80</guid>
<pubDate>Thu, 19 Mar 2009 05:32:34 GMT</pubDate>
</item>
</channel>
</rss>
eorss

    proxies = @rosin.find_proxy_instances(rss)
    proxies.size.should == 1
    proxy = proxies.first
    proxy.host.should == '201.89.84.67'
    proxy.port.should == '80'
    proxy.country.should == 'br'
  end
end
