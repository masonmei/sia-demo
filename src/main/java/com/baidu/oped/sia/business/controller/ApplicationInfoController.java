package com.baidu.oped.sia.business.controller;

import com.baidu.oped.sia.business.configuration.ApplicationProperties;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

/**
 * Created by mason on 12/3/15.
 */
@RestController
@RequestMapping("/application")
public class ApplicationInfoController {

    @Autowired
    private ApplicationProperties properties;

    @RequestMapping(value = {"info"},
                    method = RequestMethod.GET)
    public ApplicationProperties.Info getApplicationInfo() {
        return properties.getInfo();
    }

}
