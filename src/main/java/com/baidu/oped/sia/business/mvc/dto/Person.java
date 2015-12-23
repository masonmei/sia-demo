package com.baidu.oped.sia.business.mvc.dto;

import java.io.Serializable;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotNull;

/**
 * Person DTO.
 *
 * @author mason
 */
public class Person implements Serializable {
    private static final long serialVersionUID = -3454758774684124324L;

    @NotNull
    private String name;
    @Min(value = 10, message = "com.baidu.oped.sia.business.mvc.dto.Person.age.min")
    private int age;
    private String brief;

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

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
