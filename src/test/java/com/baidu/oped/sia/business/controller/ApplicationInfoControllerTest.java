package com.baidu.oped.sia.business.controller;

import static org.hamcrest.core.Is.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.baidu.oped.sia.business.Application;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.SpringApplicationConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

/**
 * Created by mason on 12/8/15.
 */
@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(value = {Application.class})
@WebAppConfiguration
public class ApplicationInfoControllerTest {

    @Autowired
    private WebApplicationContext context;

    private MockMvc mvc;

    @Before
    public void setUp() throws Exception {
        this.mvc = MockMvcBuilders.webAppContextSetup(context).build();
    }

    @Test
    public void testGetApplicationInfo() throws Exception {
        mvc.perform(get("/application/info")).andExpect(status().isOk()).andDo(print()).andExpect(content()
                .json("{\"version\":\"0.0.1\"," + "\"department\":\"oped\"," + "\"description\":\"Demo程序\","
                        + "\"contact\":\"meidongxu@baidu.com\"}")).andExpect(jsonPath("$.version", is("0.0.1")));
    }
}