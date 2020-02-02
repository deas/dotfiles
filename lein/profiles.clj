;; https://github.com/technomancy/leiningen/blob/stable/doc/PROFILES.md
;; https://github.com/magomimmo/modern-cljs/blob/master/doc/tutorial-18.md
{:user {:gorilla-options {:port 9090}
        :plugins [
                  ;; [walmartlabs/vizdeps "0.1.6"]
                  ;; [lein-tools-deps "0.4.5"] 
                  [lein-hiera "1.1.0"] 
                  [lein-try "0.4.3"]
                  [lein-pprint "1.2.0"]
                  [lein-ancient "0.6.15"]
                  [lein-bikeshed "0.5.2"]
                  [venantius/yagni "0.1.7"]
                  [jonase/eastwood "0.3.5"]
                  ;; [lein-nevam "0.1.2"]
                  ]
;;        :dependencies [[slamhound "1.3.1"]]}}
}}
