import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

/// Maps Bootstrap Icons names from the API (e.g. "bi-hospital") to the
/// real [BootstrapIcons] — pixel-perfect with the web dashboard.
IconData bootstrapIconToMaterial(
  String? bootstrapName, {
  bool isClinic = true,
}) {
  final key = (bootstrapName ?? '').trim().toLowerCase().replaceAll('_', '-');
  switch (key) {
    // Clinic / location
    case 'bi-hospital':
      return BootstrapIcons.hospital;
    case 'bi-hospital-fill':
      return BootstrapIcons.hospital_fill;
    case 'bi-building':
      return BootstrapIcons.building;
    case 'bi-building-fill':
      return BootstrapIcons.building_fill;
    case 'bi-geo-alt':
      return BootstrapIcons.geo_alt;
    case 'bi-geo-alt-fill':
      return BootstrapIcons.geo_alt_fill;
    case 'bi-pin':
      return BootstrapIcons.pin;
    case 'bi-pin-fill':
      return BootstrapIcons.pin_fill;
    case 'bi-pin-map':
      return BootstrapIcons.pin_map;
    case 'bi-pin-map-fill':
      return BootstrapIcons.pin_map_fill;
    case 'bi-house':
      return BootstrapIcons.house;
    case 'bi-house-fill':
      return BootstrapIcons.house_fill;
    case 'bi-house-door':
      return BootstrapIcons.house_door;
    case 'bi-house-door-fill':
      return BootstrapIcons.house_door_fill;

    // Online channels
    case 'bi-camera-video':
      return BootstrapIcons.camera_video;
    case 'bi-camera-video-fill':
      return BootstrapIcons.camera_video_fill;
    case 'bi-webcam':
      return BootstrapIcons.webcam;
    case 'bi-webcam-fill':
      return BootstrapIcons.webcam_fill;
    case 'bi-telephone':
      return BootstrapIcons.telephone;
    case 'bi-telephone-fill':
      return BootstrapIcons.telephone_fill;
    case 'bi-phone':
      return BootstrapIcons.phone;
    case 'bi-phone-fill':
      return BootstrapIcons.phone_fill;
    case 'bi-mic':
      return BootstrapIcons.mic;
    case 'bi-mic-fill':
      return BootstrapIcons.mic_fill;
    case 'bi-mic-mute':
      return BootstrapIcons.mic_mute;
    case 'bi-mic-mute-fill':
      return BootstrapIcons.mic_mute_fill;
    case 'bi-chat':
      return BootstrapIcons.chat;
    case 'bi-chat-fill':
      return BootstrapIcons.chat_fill;
    case 'bi-chat-dots':
      return BootstrapIcons.chat_dots;
    case 'bi-chat-dots-fill':
      return BootstrapIcons.chat_dots_fill;
    case 'bi-chat-text':
      return BootstrapIcons.chat_text;
    case 'bi-chat-text-fill':
      return BootstrapIcons.chat_text_fill;
    case 'bi-chat-left':
      return BootstrapIcons.chat_left;
    case 'bi-chat-left-fill':
      return BootstrapIcons.chat_left_fill;

    // Misc
    case 'bi-calendar':
      return BootstrapIcons.calendar;
    case 'bi-calendar-fill':
      return BootstrapIcons.calendar_fill;
    case 'bi-calendar-check':
      return BootstrapIcons.calendar_check;
    case 'bi-calendar-check-fill':
      return BootstrapIcons.calendar_check_fill;
    case 'bi-calendar-event':
      return BootstrapIcons.calendar_event;
    case 'bi-clock':
      return BootstrapIcons.clock;
    case 'bi-clock-fill':
      return BootstrapIcons.clock_fill;
    case 'bi-person':
      return BootstrapIcons.person;
    case 'bi-person-fill':
      return BootstrapIcons.person_fill;
    case 'bi-people':
      return BootstrapIcons.people;
    case 'bi-people-fill':
      return BootstrapIcons.people_fill;
    case 'bi-heart':
      return BootstrapIcons.heart;
    case 'bi-heart-fill':
      return BootstrapIcons.heart_fill;
    case 'bi-heart-pulse':
      return BootstrapIcons.heart_pulse;
    case 'bi-heart-pulse-fill':
      return BootstrapIcons.heart_pulse_fill;
    case 'bi-activity':
      return BootstrapIcons.activity;
    case 'bi-envelope':
      return BootstrapIcons.envelope;
    case 'bi-envelope-fill':
      return BootstrapIcons.envelope_fill;
    case 'bi-star':
      return BootstrapIcons.star;
    case 'bi-star-fill':
      return BootstrapIcons.star_fill;
    case 'bi-globe':
      return BootstrapIcons.globe;
    case 'bi-globe2':
      return BootstrapIcons.globe2;
    case 'bi-laptop':
      return BootstrapIcons.laptop;
    case 'bi-laptop-fill':
      return BootstrapIcons.laptop_fill;
    case 'bi-video':
      return BootstrapIcons.camera_video;
    case 'bi-video-fill':
      return BootstrapIcons.camera_video_fill;
    case '':
      return isClinic ? BootstrapIcons.hospital : BootstrapIcons.camera_video;
    default:
      // Unknown bi-* name: fall back to the section default.
      return isClinic ? BootstrapIcons.hospital : BootstrapIcons.camera_video;
  }
}
