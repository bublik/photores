module CounterAndAdvert

  def google_verify_code
    return '' if APP_CONFIG['google_verify'][APP_CONFIG['domain']].blank?
    '<meta name="verify-v1" content="'+APP_CONFIG['google_verify'][APP_CONFIG['domain']]+'" />'.html_safe
  end
  
  def google_analytix_adds
    return '' if APP_CONFIG['google_analytics'][APP_CONFIG['domain']].blank?
    '<script type="text/javascript">
      window.google_analytics_uacct = "'+APP_CONFIG['google_analytics'][APP_CONFIG['domain']]+'";
    </script>'
  end
  
  def google_analytics
    return '' if APP_CONFIG['google_analytics'][APP_CONFIG['domain']].blank?
    '<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src=\'" + gaJsHost + "google-analytics.com/ga.js\' type=\'text/javascript\'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("'+APP_CONFIG['google_analytics'][APP_CONFIG['domain']].html_safe+'");
pageTracker._setDomainName(".'+APP_CONFIG['domain'].html_safe+'");
pageTracker._trackPageview();
} catch(err) {}
</script>'.html_safe
  end

  def google_advert_horizont_links
    return '' if Rails.env.eql?('development')
    '<script type="text/javascript"><!--
google_ad_client = "pub-1004778522513778";
/* photo-728x15 */
google_ad_slot = "7855314962";
google_ad_width = 728;
google_ad_height = 15;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>'.html_safe
  end

  def google_polubaner
    return '' if Rails.env.eql?('development')
    '<script type="text/javascript"><!--
google_ad_client = "pub-1004778522513778";
/* 468x60, создано 20.06.09 */
google_ad_slot = "4174668336";
google_ad_width = 468;
google_ad_height = 60;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>'.html_safe
  end

  def google_advert_block_links
    return '' if Rails.env.eql?('development')
    '<script type="text/javascript"><!--
google_ad_client = "pub-1004778522513778";
/* photo-200x200 */
google_ad_slot = "7994008426";
google_ad_width = 200;
google_ad_height = 200;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>'.html_safe
  end
  
  def bookmark_button
    return ''
    '<script type="text/javascript">addthis_pub  = \'bublik\'; addthis_brand = \''+APP_CONFIG['domain']+'\'; </script>
<noindex><a href="http://www.addthis.com/bookmark.php" rel="nofollow" onmouseover="return addthis_open(this, \'\', \'[URL]\', \'[TITLE]\')" onmouseout="addthis_close()" onclick="return addthis_sendto()"><img src="http://s9.addthis.com/button1-bm.gif" width="125" height="16" border="0" alt="" /></a></noindex>
<script type="text/javascript" src="http://s7.addthis.com/js/152/addthis_widget.js"></script>'
  end

  def bigmir_counter
    code = APP_CONFIG['bigmir_code'][APP_CONFIG['domain']]
    return '' if code.blank?
    "<!--bigmir)net TOP 100--><noindex>
<script type=\"text/javascript\" language=\"javascript\"><!--
bmN=navigator,bmD=document,bmD.cookie='b=b',i=0,bs=[],bm={v:#{code},s:#{code},t:29,c:bmD.cookie?1:0,n:Math.round((Math.random()* 1000000)),w:0};
for(var f=self;f!=f.parent;f=f.parent)bm.w++;
try{if(bmN.plugins&&bmN.mimeTypes.length&&(x=bmN.plugins['Shockwave Flash']))bm.m=parseInt(x.description.replace(/([a-zA-Z]|\s)+/,''));
else for(var f=3;f<20;f++)if(eval('new ActiveXObject(\"ShockwaveFlash.ShockwaveFlash.'+f+'\")'))bm.m=f}catch(e){;}
try{bm.y=bmN.javaEnabled()?1:0}catch(e){;}
try{bmS=screen;bm.v^=bm.d=bmS.colorDepth||bmS.pixelDepth;bm.v^=bm.r=bmS.width}catch(e){;}
r=bmD.referrer.slice(7);if(r&&r.split('/')[0]!=window.location.host){bm.f=escape(r);bm.v^=r.length}
bm.v^=window.location.href.length;for(var x in bm) if(/^[vstcnwmydrf]$/.test(x)) bs[i++]=x+bm[x];
bmD.write('<a href=\"http://www.bigmir.net/\" target=\"_blank\"  rel=\"nofollow\" onClick=\"img=new Image();img.src=&quot;http://www.bigmir.net/?cl=#{code}&quot;;\"><img src=\"http://c.bigmir.net/?'+bs.join('&')+'\"  width=\"160\" height=\"19\" border=\"0\" alt=\"bigmir)net TOP 100\" title=\"bigmir)net TOP 100\"></a>');
//-->
</script>
<noscript>
<a href=\"http://www.bigmir.net/\" target=\"_blank\" rel=\"nofollow\"><img src=\"http://c.bigmir.net/?v#{code}&s#{code}&t29\" width=\"160\" height=\"19\" alt=\"bigmir)net TOP 100\" title=\"bigmir)net TOP 100\" border=\"0\" /></a>
</noscript></noindex>
<!--bigmir)net TOP 100-->".html_safe
  end
end
