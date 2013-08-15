#' v3local.vcl
# denne varnishen har 2 funksjoner: varnishlag mellom varish-esi og v3 appene, 
# og et varnishlag mellom v3 appene og relax serverne. Generell ruter på port 80, 
# lokalt på v3 boksene.

# ACL
include "ACL/acl_purge.vcl";
include "ACL/acl_localnet.vcl";
# include "ACL/acl_mittari.vcl";
include "include/vsf012.vcl";
# Backends 
include "backend/backend.v3local.vcl";

# syslog på restart av 500 feil
#import std;

sub vcl_recv {

    include "include/https_anti_spoofing.vcl";

    set req.grace = 30s;

    # purge rutine
    if (req.request == "PURGE") {
            if (!client.ip ~ purge) {
                    error 405 "Not allowed.";
            }

            ban("obj.http.cache-control ~ group=" + {"""} + req.url + {"""});
            # purge("obj.http.cache-control ~ group=%22" req.url "%22");
            error 200 "Purged";
    }



    if ( req.url == "/varnish-ping" ) {
        error 200 "OK";
    }

    # aksesskontroll
    # hvis du har en x-forwaded-for header, kommer du fra en proxy og er utrygg.
    # hvis du kommer direkte utenfra mot medusa eller apiadmin er du utrygg
    # denne lista kan utvides her, ruting ordnes for seg senere.
    # if (req.url ~ "^/medusa/" || req.url ~ "/apiadmin/") {
# DEAKTIVERT: 10:04 <@brumle> men det er jo et admingrensesnitt som brukes av support og andre her

#    if ( req.url ~ "^/medusa/" ) {
#        if ( req.http.X-Forwarded-For || !(client.ip ~ localnet) ){
#		error 403 "Forbidden";
#        }
    # aksesskontroll mittari
#    if ((req.url ~ "/mittari") && !(req.url ~ "/mittari/c")) {
#        if ( !(client.ip ~ mittari) ) {
#           error 403 "Forbidden";
#        }
#    }

    # default backend
    set req.backend = seamstress;

   if (req.url ~  "^/logginn/" ) {   # NB: /logginn/, not /login/
      #if (req.http.host ~ "\..*\.dev.abctech-thailand.com") {
      #  set req.http.x-login-host = regsub(req.http.host, ".*\.(.*\.dev.abctech-thailand)", "login.\1");
      #} else {
        set req.http.x-login-host = "login.api.no.siam.dev.abctech-thailand.com";
      #}
      set req.url = regsub(req.url, "/$", ""); # remove trailing / from request, prevents // in result 
      set req.url = "http://" + req.http.x-login-host + regsub(req.url, "^/logginn/", "/API/janus/hanuman/auth/login_by_token/" ) + "/?_spring_security_remember_me=on&domain=" + req.http.host;
      unset req.http.x-login-host; 
      error 755; 
    # end of logins-handling
   }  
    # if url treet.
    elseif (req.url ~ "^/atomizer/") {
        set req.backend = atomizer;
        return(pass);

     } elsif (req.url ~ "^/apay/" || req.url ~ "^/apaygwmock/" || req.url ~ "^/apayclient" ) { 
       set req.backend = apay;
     } elsif (req.url ~ "^/amail/" || req.url ~ "^/amailclientmock/" ) {
      set req.backend = amail;
     } elsif (req.url ~ "^/puls" ) {
      set req.backend = puls;
     } elsif (req.url ~ "^/hydra" ) {
      set req.backend = hydra;
     } elsif (req.url ~ "^/mittari" ) {
      set req.backend = mittari;
     }
     #elsif (req.url ~ "^/mittari/" ) {
    #    set req.backend = mittari;

    #} elsif (req.url ~ "^/zprobooking/" ) {
    #    set req.backend = zprobooking;

    elsif (req.url ~ "^/vis/rubrikk/onlinebooking/" ) {
        set req.backend = onlinebooking;

    } #elsif (req.url ~ "^/admapper/") {
    #    set req.backend = admapper;

    #} elsif (req.url ~ "^/medusa/" ) {
    #    set req.backend = medusa;

    #} elsif (req.url ~ "^/hydra/" && req.http.X-Forwarded-Protocol != "https" && !(client.ip ~ localnet)) {
    #    set req.url = "https://" + req.http.host + req.url;
    #    error 755;

    #} elsif (req.url ~ "^/hydra/") {
    #    set req.backend = hydra;

    #} elsif (req.url ~ "^/aws/" || req.url ~ "^/meetix/" || req.url ~ "^/redirect" || req.url ~ "^/zservices" ) { 
    #    set req.backend = domus;

    #} elsif (req.http.Host == "admin.api.no" && req.url ~ "^/$") {
    #    set req.url = "http://admin.api.no/hydra/";
    #    error 755;
    
    #} elsif (req.url ~ "^/apollo/") {
    #    set req.backend = apollo;

    elsif (req.url ~ "^/relax") {
        set req.http.Host = "siam:80";
        set req.backend = relax_oslo;
    }
    elsif (req.url ~ "^/componada/") {
        set req.http.Host = "siam:80";
        set req.backend = componada;

    # } elsif (req.url ~ "^/vis/" || req.http.host ~ "^r.api.no") {
    #    set req.backend = seamstress;

    } #elsif (req.url ~ "^/build/harbour/" || req.url ~ "^/harbour/") {
      #  set req.backend = harbour;

    elsif (req.url ~ "^/iris/") {
        set req.backend = iris;
    } elsif (req.url ~ "^/API/iris/") { 
        # denne trengs frem til vi har løst problemet med flere contextpath i en jetty 
        set req.url = regsub(req.url, "/API/iris/", "/iris/"); 
        set req.backend = iris; 

    } #elsif (req.url ~ "^/hermes/") {
      #  set req.backend = hermes;
    #}
    elsif (req.url ~ "^/corredor/") {
        set req.backend = corredor;
    } elsif (req.url ~ "^/API/corredor/") { 
       # denne trengs frem til vi har løst problemet med flere contextpath i en jetty 
        set req.url = regsub(req.url, "/API/corredor/", "/corredor/"); 
        set req.backend = corredor;

    } 
    elsif (req.url ~ "^/obscura/" || req.http.host ~ "^g.api.no" || req.http.host ~ "^s.api.no" ){
	if (req.url ~"/zett/") {
		set req.backend = obscura_bkk;
	}
	else {
        	set req.backend = obscura_oslo;
	}
	set req.http.Host = "siam:80";
    } elsif (req.url ~ "^/API/obscura/") { 
        # denne trengs frem til vi har løst problemet med flere contextpath i en jetty 
        set req.url = regsub(req.url, "/API/obscura/", "/obscura/");
	if (req.url ~"/zett/") {
                set req.backend = obscura_bkk;
        }
        else {
                set req.backend = obscura_oslo;
        }
        set req.http.Host = "siam:80";

    } #elsif (req.url ~ "^/tailor/") {
      #  set req.backend = tailor;

    #} 
    elsif (req.url ~ "^/pocit") {
	#set req.http.Host = "siam:80";
        set req.backend = pocit;
        #        set req.backend = pocit_backend_1;
        #if(!req.backend.healthy || req.restarts==1) { set req.backend = pocit_backend_2; }
    #    set req.backend = pocit;
    
    } elsif (req.url ~ "^/hanuman/" || req.url ~ "^/hanumanmockclient/") {
        set req.backend = hanuman;

    #}elsif (req.url ~ "^/materia/") {
#        set req.backend = materia;

    } elsif (req.url ~ "^/transition"){
        set req.backend = transition;

    #} elsif (req.url ~ "^/solr3/.*/admin"){
        # deny access via varnish, this is available to the world
    #    error 403 "Forbidden";

    #} elsif (req.url ~ "^/solr3/"){
    #    set req.backend = solr3;
    #    return(pass);

    #} elsif (req.url ~ "^/muvi/"){
    #    set req.backend = muvi;
    #    return(pass);

    #} elsif (req.url ~ "^/zadmin/"){
    #    set req.backend = domus;

    #} elsif (req.url ~ "^/zeeland/"){
    #    set req.backend = domus;

    #} elsif (req.url ~ "^/ohnoes/"){
    #    set req.backend = ohnoes;

    } elsif (req.url ~ "^/API/janus/"){
        set req.backend = janus;

    } elsif (req.url ~ "^/candidate/"){
        set req.backend = candidate;

    } elsif (req.url ~ "^/zmapfetcher/"){
        set req.backend = zmapfetcher;

    } elsif (req.url ~ "^/frontgrabber/"){
	set req.backend = frontgrabber;
    } 
 
    #elsif (req.url ~ "^/API/zfeeds/"){
    #    set req.backend = zfeeds;

    #} elsif (req.url ~ "^/pravda/"){
     #   set req.backend = pravda;

    #} elsif (req.url ~ "^/pantera/"){
    #    set req.backend = pantera;

    # img.zett.no redirects 
    elsif (req.http.host ~ "^img.zett.no|^img.test.zett.no"){
        if (req.url ~ "^/0/0/") {
            # /0/0/ viser seg å være en mye brukt måte å si /origo/orig/ på
            set req.url = regsub(req.url, "^/0/0/", "/orig/orig/");
        }
        if (req.url ~ "^/orig/orig/") {

            set req.url = regsub(req.url, "^/orig/orig", "/zett/tindeimport/spools/images");

            # need to set host to differentiate from escenic images
            set req.http.host = "img.zett.no";

            # fetch originals (and aliases for "do nothing") directly from the backend 
            #set req.backend = drbd;

            # TODO: Sjekke ttl mot DRBD

        } else {
            # find the version (prepend it with zett_)
            set req.http.X-version  = regsub(req.url, "^/([a-zA-Z0-9]*)/.*", "zett_\1");
            # replace version info in request to get us the original image
            set req.http.X-original = regsub(req.url, "^/[a-zA-Z0-9]*/[a-zA-Z0-9]*/(.*)", "/orig/orig/\1");
            # full (encoded) url to "external" resource 
            set req.http.X-original = {"http%3A%2F%2F"} + req.http.host + regsuball(req.http.X-original, "/", {"%2F"});
            # which obscura should we use? 
            if ( req.http.host ~ "test" ) {
                set req.http.X-ObscuraHost = "g.test.api.no";
            } else {
                set req.http.X-ObscuraHost = "g.api.no";
            }
            # TODO: Sjekke om versjonen er blant de vi faktisk har portet, ellers er det bedre å levere en 404
            # redirect 
            set req.url = "http://" + req.http.X-ObscuraHost + "/obscura/external/" + req.http.X-version + "/" + req.http.X-original; 
            error 755;
        }
    }
}

sub vcl_hit {
    # so we can pick it up in vcl_deliver
    if (obj.ttl < 0s){
        set req.http.graceineffect = "true" ;
    } 
}

sub vcl_fetch {
    set beresp.grace = 1h;

    # sett en timestamp, for å avsløre hit-for-pass
    set beresp.http.X-Timestamp-v3local = "[" + server.hostname + " ; " + now + "]";
    
    if ( beresp.http.Surrogate-Control ~ "ESI/1.0" ) {
       set beresp.do_esi = true;
       set beresp.do_gzip = true;
    }
    else if ( beresp.http.content-type ~ "^(text|application/x-javascript)") {
       set beresp.do_gzip = true;
    }

    # CORE-323 - cache-control in obscura is utterly broken
    # Obscura sets Expires:, and sets max-age=86400 for all objects
    if (req.url ~ "/obscura/") {
      remove beresp.http.Expires;
      if (beresp.status != 200) {
        set beresp.http.cache-control = "max-age=60";
      } elseif (req.url ~ "^/obscura/pub/") {
        set beresp.http.cache-control = regsub(beresp.http.cache-control, "max-age=[0-9]*, ", "max-age=315360000, ");
      } elseif (req.url ~ "^/obscura/nifs/") {
        set beresp.http.cache-control = regsub(beresp.http.cache-control, "max-age=[0-9]*, ", "max-age=315360000, ");
      } elseif (req.url ~ "^/obscura/external/") {
        set beresp.http.cache-control = regsub(beresp.http.cache-control, "max-age=[0-9]*, ", "max-age=1800, ");
	# reduce ttl - this must never be more than max-age when there is another varnish in front
        set beresp.ttl = 1800s;
      }
    }
       # Ticket #786 ESI includes don't follow 301 and 302 redirects 
    if ( req.http.x-orig-cc ) { 
        set beresp.http.Cache-Control = req.http.x-orig-cc + ", " + beresp.http.Cache-Control; 
    } 
    if (beresp.status == 307){ 
        # TODO: Gå over normaliseringen av Host:, vi har forsøkt å fikse dette annetstedshen også
        # TODO: Vurdere å flytte denne blokka til varnish-v3local
        set req.http.x-orig-url = req.url; 
        set req.http.x-orig-cc = beresp.http.cache-control; 
        set req.url = regsub(beresp.http.location, "http://[^/]*","");
        return (restart); 
    }
    # reduce high ttl's to something we can live with
    if (beresp.ttl > 1440m){
        set beresp.ttl = 1440m;
    }
   if (req.url ~ "\.do$") {
        set beresp.ttl = 0s;
    } elsif (req.url ~ "^/do/") {
        set beresp.ttl = 0s;
    } elsif (beresp.http.Cache-Control ~ "no-") { 
    # Don't cache no-cache and no-store
        set beresp.ttl = 0s;
    } elsif (beresp.status == 400 || beresp.status > 404) {
        # nasty errors. syslog them
        std.syslog(180, "Error " + beresp.status +" on http://" + req.http.Host + req.url + " (" + beresp.response + ") (" + beresp.backend.name + ") (" + req.xid + ")");
        set beresp.ttl = 60s;

    } elsif (beresp.status == 404) {
        set beresp.ttl = 60s;
    }

    set beresp.http.X-Src-Webcache = "siam";
    # set beresp.cacheable = true;

    # relax brekekr av og til, og returnerer 500 på seksjoner som "forsiden" eller andre populære seksjoner
    # restart, og test om den andre har noe bedre.
    # (i tillegg er det selvsagt legitime 500 feil, så ikke ta helt av)
    if (beresp.status == 500 && req.restarts < 1  ) {
        set beresp.saintmode = 7s;
        std.syslog(180, "Error 500, saintmode for http://" + req.http.Host + req.url + " (" + beresp.response + ") (" + beresp.backend.name + ") (" + req.xid + ")");
        return(restart);
    }

    #if (beresp.status != 200 && req.url ~ "^/relax"){
       # set beresp.ttl = 2s;

    #} 
    elsif (req.url ~ "/apiadmin/ping$") {
        set beresp.ttl = 1s;
        set beresp.grace = 2s;

    } elsif (beresp.status == 400 || beresp.status > 404) {
        # nasty errors. syslog them
        std.syslog(180, "Error " + beresp.status +" on http://" + req.http.Host + req.url + " (" + beresp.response + ") (" + beresp.backend.name + ") (" + req.xid + ")");
        set beresp.ttl = 2s;

    } elsif (beresp.status == 404) {
        set beresp.ttl = 60s;
    }

    # Hacks because expire == date
    if (!(beresp.http.Cache-Control ~ "no-") && beresp.ttl == 0s) {
        set beresp.ttl = 1s;
    }
}

sub vcl_deliver {
    if (req.http.graceineffect) {
        set resp.http.cache-control = "max-age=4"; 
    }
    
    # Workaround til CORE-227 er fikset:
    if (req.url ~ "/iris/") {
        remove resp.http.Expires;
    }
}

sub vcl_error {
    if (obj.status == 755) {
        set obj.status = 301;
        set obj.response = "Moved Permanently";
        set obj.http.Location = req.url;
        return(deliver);
    }
} 
# vim:expandtab ts=2 sw=2 syntax=vcl filetype=vcl
