# WORK_PLAN.md - MemoZap Roadmap
> Machine-Readable | AI-Optimized | Updated: 02/11/2025 v1.4

```yaml
status: ACTIVE
current_phase: 3B_user_sharing
last_session: 49
last_updated: 02/11/2025

goals:
  primary:
    - smart_shopping_lists: NO price comparison
    - smart_inventory: location-based, auto-update
  
  principles:
    - no_mandatory_prices: optional only
    - no_mandatory_barcode: optional only
    - simplicity_first: quick product addition
    - use_existing_api: 5000 products (Shufersal)

timeline:
  total: 13_weeks
  part_a_lists: 4_weeks
  part_b_inventory: 3_weeks
  part_c_integration: 1_week
  part_d_receipt_system: 5_weeks
```

---

```yaml
part_a_lists:
  phase_0_research:
    status: DONE
    date: 27/10/2025
    completed:
      - analyzed_existing_system
      - verified_unified_list_item_no_price
      - created_list_type_filter_service
      - documented_strategy
  
  phase_1_extend_types:
    status: DONE
    week: 1
    priority: HIGH
    completed:
      - shopping_list_model_8_types
      - firebase_schema_extended
      - db_migration_executed
      - backward_compatibility
    
    types:
      - supermarket: all_5000_products
      - pharmacy: hygiene_cleaning
      - greengrocer: fruits_vegetables
      - butcher: meat_poultry
      - bakery: bread_pastries
      - market: mixed_fresh
      - household: custom_items
      - other: fallback
  
  phase_2_smart_filtering:
    status: DONE
    week: 1_2
    priority: HIGH
    completed:
      - list_type_filter_service
      - category_mapping_7_types
      - products_provider_connected
      - lazy_loading_100_initial
  
  phase_3_ui_ux:
    status: PAUSED
    week: 2
    priority: MEDIUM
    started: 29/10/2025
    completed:
      - list_type_selection_8_types
      - type_icons_labels
      - type_indicator_cards
      - type_filtering_screen
    remaining_optional:
      - product_search_dialog
      - type_based_suggestions
      - animations_transitions
      - e2e_testing

---

  phase_3a_frequency_reminders:
    status: TODO_FUTURE
    week: 2
    priority: LOW
    
    model_changes:
      shopping_list:
        - frequency_int_times_per_week
        - last_shopping_date_datetime
        - build_runner_required
    
    tasks:
      - frequency_selector_ui_1_7_per_week
      - reminder_service_calculate_next_date
      - push_notifications_frequency_based
      - smart_reminder_3_days_before
      - settings_enable_disable_per_list

---

  phase_3b_user_sharing:
    status: IN_PROGRESS
    week: 2_3
    priority: HIGH
    started: session_46
    progress: 22_percent
    
    models_done:
      - shared_user: userId_role_sharedAt
      - pending_request: id_requesterId_itemData_status_requestedAt
      - user_role_enum: owner_admin_editor_viewer
    
    services_done:
      share_list_service:
        lines: 460
        session: 46
        methods:
          - invite_remove_update_user
          - can_edit_approve_manage
          - get_users_stats_is_shared
      
      pending_requests_service:
        lines: 410
        session: 47
        methods:
          - create_approve_reject_request
          - cleanup_old_7_days
          - get_pending_count_stats
      
      tests:
        total: 64
        coverage: services_100_percent
    
    permission_levels:
      owner:
        - add_items_directly_no_approval
        - approve_reject_editor_requests
        - can_delete_list
        - manage_user_permissions
      
      admin:
        - add_items_directly_no_approval
        - approve_reject_editor_requests
        - cannot_delete_list
        - manage_user_permissions
      
      editor:
        - see_full_list_read_only
        - add_items_creates_pending_request
        - needs_approval_from_owner_admin
        - item_not_visible_until_approved
        - cannot_edit_delete_existing
      
      viewer:
        - read_only_access
        - cannot_add_requests
        - cannot_edit_anything
    
    remaining_ui:
      - invite_users_screen_email_role
      - manage_users_screen_list_edit_roles
      - pending_requests_screen_badge_approve_reject
      - permission_validation_ui
      - notifications_approved_rejected_invited
      - firebase_security_rules
      - testing_4_permission_levels
    
    user_flow:
      - owner_creates_invites_assigns_roles
      - editor_adds_item_creates_pending_request
      - owner_admin_sees_badge_reviews
      - approved_adds_to_list_notifies_editor
      - rejected_deletes_notifies_editor

---

  phase_4_product_management:
    status: TODO
    week: 3
    priority: MEDIUM
    tasks:
      - products_manager_singleton
      - lazy_loading_per_type
      - hive_cache_integration
      - memory_optimization
      - offline_support
  
  phase_5_testing_polish:
    status: TODO
    week: 3_4
    priority: HIGH
    tasks:
      - test_scenarios_filtering_no_price_performance
      - loading_animations
      - empty_state_messages
      - error_handling
      - hebrew_translations
      - rtl_support_verification

success_metrics:
  done:
    - 7_list_types_working
    - filter_reduces_80_percent
  pending:
    - ui_selection_under_2_taps
    - cache_hit_rate_90_percent
    - all_tests_passing

not_building:
  - price_comparison_app
  - barcode_scanner_maybe_later
  - complex_inventory_system
  - store_specific_prices

building:
  - simple_list_manager
  - quick_product_addition
  - smart_categorization
  - offline_support

related_docs:
  - CODE.md: v2.2_500_lines
  - DESIGN.md: v1.1_300_lines
  - TECH.md: v1.3_400_lines
  - PROJECT_INSTRUCTIONS.md: v4.9_500_lines
  - CODE_REVIEW_CHECKLIST.md: v2.4_300_lines
  total: 5_files_2000_lines
```

---

```yaml
recent_work:
  sessions_25_49:
    focus: infrastructure_before_features
    
    bug_fixes_25_33:
      - 10_files_compilation_errors
      - navigation_range_error
      - product_loading_0_to_1758
      - view_edit_modes_populate_screen
    
    docs_evolution_34_46:
      phase_1: 10_to_7_files_minus_38_percent
      phase_2: 7_to_5_files_minus_60_percent
      project_instructions: v4.0_to_v4.9
      checklist: v2.0_to_v2.4
      tech: v1.0_to_v1.3
    
    code_cleanup_35_41:
      removed: 1500_lines_dead_code
      cleaned: config_test_scripts_dirs
      protocol: 6_step_dead_code_verification
      false_positives: 5_prevented
    
    repository_38:
      created: repository_constants.dart
      migrated: 6_repos
      eliminated: magic_strings
    
    testing_44_45:
      before: 61_failures
      after: 0_failures_179_passing
      coverage: 90_percent_models
    
    memory_system_46:
      entities: 10_optimized
      protocol: auto_checkpoint
      rotation: last_3_5_sessions
      maintenance: zero
    
    animations_cleanup_49:
      fixed: 3_manual_animations
      files:
        - settings_screen: SimpleTappableCard_minus_15_lines
        - populate_list_screen: SimpleTappableCard
        - shopping_list_details_screen: AnimatedButton
      result: consistent_haptic_feedback
      saved: animated_button_98_lines_false_positive_5
    
    docs_update_49:
      code_md: v2.1_to_v2.2_component_reuse
      design_md: v1.0_to_v1.1_advanced_components
      added: decision_tree_ai_protocol
```

---

```yaml
current_status:
  infrastructure:
    status: COMPLETE
    items:
      - compilation_errors: RESOLVED
      - documentation: 5_files_2000_lines
      - testing: 179_passing_0_failures
      - memory: 10_entities_operational
      - token_management: ACTIVE
  
  phase_3b_user_sharing:
    status: IN_PROGRESS
    started: session_46
    progress: 22_percent_services_only
    
    completed_services:
      share_list_service:
        lines: 460
        features:
          - invite_remove_update_users
          - 7_permission_helpers
          - owner_only_security
      
      pending_requests_service:
        lines: 410
        features:
          - create_approve_reject
          - 7_query_methods
          - auto_cleanup_7_days
      
      tests:
        total: 64_unit_tests
        coverage: services_100_percent
    
    remaining_ui:
      - invite_users_screen
      - manage_users_screen
      - pending_requests_screen
      - permission_validation
      - notifications
      - firebase_security_rules
      - ui_testing
  
  phase_3_ui_ux:
    status: PAUSED
    completed:
      - list_type_selection_8_types
      - type_filtering
      - type_indicators
      - product_search_filtering
    remaining_optional:
      - animations_transitions
      - e2e_testing
  
  roadmap:
    next:
      - complete_phase_3b_ui
      - phase_4_product_management
      - phase_5_testing_polish
    future:
      - phase_6_8_inventory_system
      - phase_9_integration
      - phase_10_14_receipt_system
```

---

---

```yaml
part_b_inventory:
  phase_6_storage_infrastructure:
    status: TODO
    week: 5
    priority: HIGH
    
    model_changes:
      inventory_item:
        - minimum_threshold_int_default_0
        - last_updated_datetime
        - build_runner_required
    
    tasks:
      - update_inventory_item_model
      - storage_location_service
      - firebase_location_field
      - migration_existing_items
      - update_repositories
  
  phase_6a_threshold_system:
    status: TODO
    week: 5
    priority: HIGH
    tasks:
      - threshold_editor_ui_default_0
      - threshold_monitor_service
      - auto_add_when_quantity_less_than_threshold
      - route_to_correct_list_type
      - badge_auto_added_items
      - settings_enable_disable_per_item
      - notification_low_stock_added
  
  phase_7_ui_custom_locations:
    status: TODO
    week: 6
    priority: HIGH
    
    ui_tasks:
      - inventory_screen_dart
      - unassigned_items_bar_widget
      - location_based_display
      - quick_assignment_single_row
      - animations_item_assignment
      - empty_states_per_location
    
    custom_locations:
      model:
        - id_name_icon_householdId_createdBy
      service:
        - custom_locations_service_crud
      ui:
        - add_location_dialog_name_icon
        - edit_delete_locations
      logic:
        - appear_in_quick_assignment
      firebase:
        - custom_locations_collection
      validation:
        - max_20_per_household
  
  phase_8_stock_management:
    status: TODO
    week: 7
    priority: MEDIUM
    tasks:
      - stock_update_service
      - unpack_shopping_flow
      - physical_check_flow
      - location_learning_algorithm
      - auto_assignment_logic
      - testing_real_data
  
  phase_8a_predictive_stock:
    status: TODO_FUTURE
    week: 7
    priority: LOW
    tasks:
      - stock_prediction_service
      - track_purchase_frequency
      - calculate_consumption_rate
      - predict_runout_time
      - auto_add_before_runout
      - predicted_low_stock_badge
      - testing_2_weeks_data_needed
```

---

```yaml
part_c_integration:
  phase_9_lists_inventory:
    status: TODO
    week: 8
    priority: HIGH
    tasks:
      - connect_inventory_to_suggestions
      - auto_routing_to_list_types
      - shopping_completion_flow
      - weekly_list_generation
      - cross_system_notifications
      - e2e_testing
  
  phase_9a_cumulative_inventory:
    status: TODO
    week: 8
    priority: HIGH
    tasks:
      - cumulative_calculation_existing_plus_purchased
      - example_2_plus_5_equals_7
      - ui_show_before_after_quantities
      - ui_message_you_had_2_bought_5_now_7
      - inventory_cumulative_service
      - validation_prevent_negative
      - history_track_changes_optional
```

---

```yaml
part_d_receipt_to_inventory:
  overview:
    goal: collaborative_shopping_to_auto_inventory_update
    concept:
      - collaborative_shopping_multiple_people
      - virtual_receipt_auto_created_on_finish
      - real_receipt_connection_scan_later
      - inventory_update_auto_from_purchased
  
  phase_10_shopping_session:
    status: TODO
    week: 9
    priority: HIGH
    
    models_done:
      - active_shopper: userId_joinedAt_isStarter_isActive
      - shopping_list: activeShoppers_field_8_helpers
      - receipt_item: checkedBy_checkedAt
      - receipt: linkedShoppingListId_isVirtual_createdBy
    
    tasks:
      - start_shopping_ui_join_button
      - shopping_session_service_join_leave_timeout
      - starter_assignment_first_person
      - power_transfer_first_helper_becomes_starter
      - timeout_6_hours_auto_end
      - notifications_join_leave
  
  phase_11_virtual_receipt:
    status: TODO
    week: 10
    priority: HIGH
    tasks:
      - virtual_receipt_service
      - on_finish_create_virtual_receipt
      - filter_only_purchased_items
      - store_linked_shopping_list_id
      - receipt_virtual_factory_done
      - show_virtual_receipt_ui
      - validation_only_starter_finish
  
  phase_12_ocr_connection:
    status: TODO
    week: 11
    priority: MEDIUM
    tasks:
      - receipt_ocr_service_scan_parse
      - matching_ocr_to_virtual_items
      - update_real_prices_fileUrl
      - scan_receipt_screen_ui
      - manual_price_editing_if_ocr_fails
      - validation_prevent_duplicate_linking
  
  phase_13_purchased_to_inventory:
    status: TODO
    week: 12
    priority: HIGH
    tasks:
      - purchased_to_inventory_service
      - purchased_items_to_inventory_no_location
      - unpurchased_items_stay_in_list
      - cumulative_existing_2_plus_5_equals_7
      - notification_assign_locations
      - quick_location_assignment_ui
  
  phase_14_integration_testing:
    status: TODO
    week: 13
    priority: HIGH
    
    scenarios:
      - solo_shopping: start_mark_finish_virtual_to_inventory
      - collaborative: starter_helper_both_mark_receipt_shows_who
      - starter_leaving: power_transfer_first_helper
      - timeout: 6_hours_auto_end_virtual_created
      - ocr_connection: scan_match_update_prices
    
    tasks:
      - integration_tests_5_scenarios
      - edge_cases_network_crash
      - permissions_only_starter_finish
      - concurrent_shoppers_2_3_people
      - performance_100_items

success_metrics:
  part_d:
    - 100_percent_purchased_auto_inventory
    - 95_percent_virtual_receipt_success
    - 80_percent_ocr_accuracy
    - under_2_taps_assign_location
    - 70_percent_less_manual_updates
  part_b:
    - 80_percent_stock_prediction_accuracy
    - 90_percent_essential_never_runout
  overall:
    - seamless_lists_inventory_flow
    - smart_learning_2_weeks
```

---

**End of WORK_PLAN.md v1.4**  
**Machine-Readable Format | AI-Optimized**  
**Last Updated:** 02/11/2025 Session 49
