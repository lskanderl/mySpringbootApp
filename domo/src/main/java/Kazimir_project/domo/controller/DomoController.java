package Kazimir_project.domo.controller;

import Kazimir_project.domo.dto.SearchDto;
import Kazimir_project.domo.service.DomoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@RestController
public class DomoController {

    @Autowired
    DomoService domoService;

    @PostMapping(value = "/recognizeInvaders", consumes = "application/json")
    public List<Map<String, String>> postInvaders(@RequestBody SearchDto searchDto){
       return domoService.findInvaders(searchDto);
    }

    @GetMapping(value = "/invaders", produces = "application/json")
    public String getInvaders() throws IOException {
        return domoService.getInvaderJava();
    }

    @GetMapping(value = "/map", produces = "application/json")
    public String getMap() throws IOException {
        return domoService.getMapJava();
    }

}