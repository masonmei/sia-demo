package com.baidu.oped.sia.business.mvc.controller;

import com.baidu.oped.sia.business.configuration.ApplicationProperties;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

/**
 * Application Info Controller.
 *
 * @author mason
 */
@RestController
@RequestMapping("/application")
public class ApplicationInfoController {
    private static final Logger LOG = LoggerFactory.getLogger(ApplicationInfoController.class);

    @Autowired
    private ApplicationProperties properties;

    @RequestMapping(value = {"info"}, method = RequestMethod.GET)
    public ApplicationProperties.Info getApplicationInfo() {
        LOG.debug("invoking to get application info");
        return properties.getInfo();
    }

}
