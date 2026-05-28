package com.crime.management.config;

import org.apache.catalina.Context;
import org.apache.catalina.WebResourceRoot;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;
import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.io.File;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Bean
    public WebServerFactoryCustomizer<TomcatServletWebServerFactory> tomcatCustomizer() {
        return factory -> factory.addContextCustomizers((Context context) -> {
            // Register src/main/webapp so JSPs are found when running from IntelliJ
            File webappDir = new File("src/main/webapp");
            if (webappDir.exists()) {
                WebResourceRoot resources = new StandardRoot(context);
                resources.addPreResources(new DirResourceSet(
                        resources,
                        "/",
                        webappDir.getAbsolutePath(),
                        "/"
                ));
                context.setResources(resources);
            }
        });
    }
}
