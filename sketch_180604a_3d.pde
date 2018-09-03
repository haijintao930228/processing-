import processing.core.PApplet;
import processing.core.PVector;

import java.util.ArrayList;
import java.util.List;



  Formation formation;
  PVector cameraPos, cameraTarget, up, cameraFront;
  float focalLength;
  float fov, aspect, zNear, zFar;
  float yaw, pitch;
  int Num = 100;
  ArrayList<Boid> fishes;
  int width = 800;
  int height = 800;

  float MAX_SPEED = 1.5f;
  float MAX_FORCE = (float) 1;
  // 间距
  float ZOR = 30;

  float ZOO = 60;

  float LOOK_RANGE = 300;

  float LENGTH = 20;

  float FERTILITY = (float) 0.1;

  public void settings() {
    initCamera();
    size(width, height, P3D);
    formation = new Formation();
    for (int i = 0; i < Num; i++) {
      formation.addBoid(new Boid(random(width), random(height), random(height)));
    }
  }

  private void initCamera() {

    focalLength = (height / 2.0f) / tan(PI * 30.0f / 180.0f);
    cameraPos = new PVector(width / 2.0f, height / 2.0f, focalLength);
    cameraFront = new PVector(0.0f, 0.0f, -1.0f);
    up = new PVector(0.0f, 1.0f, 0.0f);

    fov = radians(60);
    aspect = (width) / (height);
    zNear = cameraPos.z / 10.0f;
    zFar = cameraPos.z * 10.0f;

    yaw = -90.0f;
    pitch = 0.0f;

  }

  void do_movement() {
    float cameraSpeed = 5.0f;
    // 移动摄影机(同时移动目标）
    if (keyPressed) {

      if (key == 'w') {
        cameraPos.add(PVector.mult(cameraFront, cameraSpeed));
      }

      if (key == 's') {
        cameraPos.sub(PVector.mult(cameraFront, cameraSpeed));
      }

      if (key == 'a') {
        PVector v = cameraFront.get();
        v = v.cross(up);
        v.normalize();
        cameraPos.sub(PVector.mult(v, cameraSpeed));
      }
      if (key == 'd') {
        PVector v = cameraFront.get();
        v = v.cross(up);
        v.normalize();
        cameraPos.add(PVector.mult(v, cameraSpeed));
      }
    }

    float sensitivity = 0.05f; 
    if (mousePressed) {
      yaw += (mouseX - pmouseX) * sensitivity;
      pitch += (mouseY - pmouseY) * sensitivity;
      if (pitch > 89.0f)
        pitch = 89.0f;
      if (pitch < -89.0f)
        pitch = -89.0f;
      cameraFront.x = cos(radians(yaw)) * cos(radians(pitch));
      cameraFront.y = sin(radians(pitch));
      cameraFront.z = sin(radians(yaw)) * cos(radians(pitch));
      cameraFront.normalize();
    }

    if (keyPressed) {

      if (key == 'r') {
        yaw = -90.0f;
        pitch = 0.0f;

        cameraFront.x = cos(radians(yaw)) * cos(radians(pitch));
        cameraFront.y = sin(radians(pitch));
        cameraFront.z = sin(radians(yaw)) * cos(radians(pitch));
        cameraFront.normalize();

        cameraPos = new PVector(width / 2.0f, height / 2.0f, focalLength);
      }
    }
  }

  public void draw() {
    smooth();
    do_movement();
    cameraTarget = PVector.add(cameraPos, cameraFront);
    camera(cameraPos.x, cameraPos.y, cameraPos.z, cameraTarget.x, cameraTarget.y, cameraTarget.z, up.x, up.y, up.z);
    perspective(fov, aspect, zNear, zFar);
    background(255);
    formation.run();
  }

  class Formation {
    Formation() {
      fishes = new ArrayList<Boid>();
    }

    public void addBoid(Boid boid) {
      fishes.add(boid);

    }

    void run() {
      for (int i = 0; i < fishes.size(); i++) {
        Boid b = fishes.get(i);
        b.run(i);
      }
    }

    void display() {
      stroke(0, 0, 0);
      fill(255, 0, 0);
      stroke(0, 0, 0);
      noFill();
    }
  }

  class Boid {
    PVector location;
    PVector velocity;
    PVector acceleration;
    float r;
    float aAcceleration;
    float thetaTem;
    float dis;
    float angle;
    PVector vector;
    float e;
    float phase;
    color Color;
    String id;
    float maxspeed;
    float maxforce;
    float separationRange;
    float lookRange;
    float length;
    float base;
    PVector wandering;
    float bite;
    PVector alignment;
    PVector cohesion;
    List<Boid> neighboors;
    List<Boid> ZOOneighboors;
    PVector separation;

    Boid(float x, float y, float z) {

      this.acceleration = new PVector(0, 0);
      float angle = random(0, TWO_PI);
      this.velocity = new PVector(cos(angle), sin(angle), random(angle));
      this.location = new PVector(x, y, z);
      this.r = 4.0f;
      this.aAcceleration = 0.04f;
      this.Color = (int) random(6);
      this.maxspeed = MAX_SPEED;
      this.maxforce = MAX_FORCE;
      this.id = System.currentTimeMillis() + "创建的鱼";
      this.ZOOneighboors = new ArrayList<Boid>();
      this.wandering = new PVector(random(-1, 1), random(-1, 1), random(-1, 1));

    }

    void swim() {
      this.ZOOneighboors.clear();
      this.lookZOO(Num, TWO_PI);
      this.shoal();
      this.check();
    }

    private void lookZOO(int num, float twoPi) {
      for (int i = 0; i < Num; i++) {
        if (fishes.get(i) != this) {
          PVector diff = PVector.sub(this.location.copy(), fishes.get(i).location);
          float anglebe = PVector.angleBetween(this.velocity, diff);
          float distan = PVector.dist(this.location, fishes.get(i).location);
          if (distan < ZOO && distan > ZOR && anglebe > TWO_PI / 3 || anglebe < PI / 3) {
            this.ZOOneighboors.add(fishes.get(i));
          }
        }
      }

    }

    private void shoal() {
      this.alignment = this.align();
      this.applyForce(this.alignment);
    }

    private PVector align() {
      PVector sum = new PVector(0, 0);
      if (this.ZOOneighboors.size() != 0) {
        for (Boid fish : this.ZOOneighboors) {
          sum.add(fish.velocity.normalize());
        }
      }
      return sum;
    }

    void run(int i) {
      update2(i);
      check();
      render(i);
    }

    private void check() {
      if (this.location.x < 1 || this.location.x > width - 1) {
        this.location.x = width - this.location.x;
      }
      if (this.location.y < 1 || this.location.y > height - 1) {
        this.location.y = height - this.location.y;
      }
    }

    private void update2(int i) {
      this.swim();
      this.update3();

    }

    private void update3() {
      this.velocity.limit(2);
      location.add(this.velocity);
    }

    void applyForce(PVector force) {
      this.velocity.add(force);
    }

    void render(int i) {
       color Color= color(random(255), random(255), random(255));

      pushMatrix();
      translate(location.x, location.y, location.z);
      rotateY(map(mouseX, 0, width, -PI, PI));
      rotateX(map(mouseY, 0, height, -PI, PI));
      beginShape();
      box(10, 10, 10);
      fill(Color);
      endShape();
      popMatrix();

      pushMatrix();
      beginShape();
      for (int i1 = 0; i1 < 50; i1++) {
        line(0, -i1 * 20, 0, -500, 0, 0);
        line(-i1 * 20, 0, 0, 0, -500, 0);
        line(0, -i1 * 20, 0, 0, 0, -500);
        line(-i1 * 20, 0, 0, 0, 0, -500);
      }
      fill(Color);
      endShape();
      popMatrix();

    }

  }