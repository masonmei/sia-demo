package com.baidu.oped.sia.business.configuration;

import com.baidu.oped.sia.business.Application;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.SpringApplicationConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;

/**
 * Created by mason on 12/8/15.
 */
@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(value = {Application.class})
@WebAppConfiguration
public class ApplicationPropertiesTest {
    @Autowired
    private ApplicationProperties properties;

    @Test
    public void testGetInfo() throws Exception {
        assertNotNull(properties.getInfo());
    }

    @Test
    public void testSetInfo() throws Exception {
        properties.setInfo(null);
        assertNull(properties.getInfo());
    }

    @RunWith(SpringJUnit4ClassRunner.class)
    @SpringApplicationConfiguration(value = {Application.class})
    @WebAppConfiguration
    public static class InfoTest {

        @Autowired
        private ApplicationProperties properties;

        @Test
        public void testGetVersion() throws Exception {
            assertNotNull(properties.getInfo().getVersion());
        }

        @Test
        public void testSetVersion() throws Exception {
            properties.getInfo().setVersion("0.0.2-SNAPSHOT");
            assertEquals("0.0.2-SNAPSHOT", properties.getInfo().getVersion());
        }

        @Test
        public void testGetDescription() throws Exception {
            assertNotNull(properties.getInfo().getDescription());
        }

        @Test
        public void testSetDescription() throws Exception {
            properties.getInfo().setDescription("Demo");
            assertEquals("Demo", properties.getInfo().getDescription());
        }

        @Test
        public void testGetDepartment() throws Exception {
            assertNotNull(properties.getInfo().getDepartment());
        }

        @Test
        public void testSetDepartment() throws Exception {
            properties.getInfo().setDepartment("sia");
            assertEquals("sia", properties.getInfo().getDepartment());
        }

        @Test
        public void testGetContact() throws Exception {
            assertNotNull(properties.getInfo().getContact());
        }

        @Test
        public void testSetContact() throws Exception {
            properties.getInfo().setContact("sia@baidu.com");
            assertEquals("sia@baidu.com", properties.getInfo().getContact());
        }
    }
}