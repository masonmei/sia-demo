package com.baidu.oped.sia.business.controller;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import com.baidu.oped.sia.business.controller.dto.Person;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * Test Controllers.
 *
 * @author mason
 */
@RestController
public class TestController {

    private static final Logger LOG = LoggerFactory.getLogger(TestController.class);

    @RequestMapping(value = "/receiveBody", method = RequestMethod.POST)
    public String bigRequest(@RequestBody List<Person> persons) {
        System.out.println(persons);
        return String.valueOf(persons.size());
    }

    @RequestMapping(value = "/consumeCPU/{max}")
    public String consumeCPU(@PathVariable("max") int max) {
        calculateSum(max);
        return "DONE";
    }

    @RequestMapping(value = "/consumeMem/{mem}")
    public String consumeMemory(@PathVariable("mem") int memory) {
        prepareMemory(memory);
        return "DONE";
    }

    @RequestMapping(value = "/consumeTime/{time}")
    public String consumeTime(@PathVariable("time") int timeInMs) {
        sleep(timeInMs);
        return "DONE";
    }

    @RequestMapping(value = "/persons", method = RequestMethod.GET)
    public List<Person> getPersons(@RequestParam("num") int number) {
        List<Person> persons = new ArrayList<>(number);
        for (int i = 0; i < number; i++) {
            Person person = new Person();
            person.setName("mason" + i);
            person.setAge(i);
            person.setBrief("This is mason " + i);
            persons.add(person);
        }
        return persons;
    }

    private void calculateSum(int to) {
        int sum = 0;
        while (to-- > 0) {
            sum += to;
        }
        System.out.println(sum);
    }

    private void prepareMemory(int count) {
        List<WeakReference<byte[]>> references = new ArrayList<>();

        for (int i = 0; i < count; i++) {
            references.add(new WeakReference<>(new byte[1024 * 1024]));
        }
    }

    private void sleep(int ms) {
        try {
            Thread.sleep(ms);
        } catch (InterruptedException e) {
            LOG.warn("sleep failed.");
        }
    }
}
