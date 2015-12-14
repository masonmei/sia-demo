package com.baidu.oped.sia.business.controller.dto;

import java.io.Serializable;

/**
 * Person DTO.
 *
 * @author mason
 */
public class Person implements Serializable {
    private String name;
    private int age;
    private String brief;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    public String getBrief() {
        return brief;
    }

    public void setBrief(String brief) {
        this.brief = brief;
    }
}
