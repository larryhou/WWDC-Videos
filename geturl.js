// https://developer.apple.com/videos/wwdc/2013/
jQuery(".download a[href*='HD']").map(function(){return this.href}).get().join('\n')

// https://developer.apple.com/videos/wwdc/2014/
jQuery(".download a[href*='hd']").map(function(){return this.href}).get().join('\n')