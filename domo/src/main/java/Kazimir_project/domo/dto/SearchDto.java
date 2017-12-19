package Kazimir_project.domo.dto;

import java.util.List;
import java.util.Map;

public class SearchDto {

    private String id;
    private String map;
    private List<Map<String, String>> invaders;

    public String getMap() {
        return map;
    }

    public void setMap(String map) {
        this.map = map;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public List<Map<String, String>> getInvaders() {
        return invaders;
    }

    public void setInvaders(List<Map<String, String>> invaders) {
        this.invaders = invaders;
    }
}


