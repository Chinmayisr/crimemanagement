package com.crime.management.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ViewController {

    @GetMapping({"/", "/home"})
    public String home() { return "index"; }

    @GetMapping("/criminals")
    public String criminals() { return "criminals"; }

    @GetMapping("/crimes")
    public String crimes() { return "crimes"; }

    @GetMapping("/victims")
    public String victims() { return "victims"; }

    @GetMapping("/officers")
    public String officers() { return "officers"; }

    @GetMapping("/cases")
    public String cases() { return "cases"; }

    @GetMapping("/evidence")
    public String evidence() { return "evidence"; }
}
