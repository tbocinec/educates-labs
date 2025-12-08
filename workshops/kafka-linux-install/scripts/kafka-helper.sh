#!/bin/bash

# Kafka Linux Install Workshop - Helper Scripts
# This script provides common operations for managing the Kafka cluster

set -e

KAFKA_HOME="${KAFKA_HOME:-$HOME/kafka}"
CLUSTER_ID_FILE="/tmp/cluster-id"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Start Kafka UI with Docker Compose
start_kafka_ui() {
    echo_info "Starting Kafka UI..."
    docker-compose up -d kafka-ui
    echo_info "Kafka UI started on http://localhost:8080"
}

# Stop Kafka UI
stop_kafka_ui() {
    echo_info "Stopping Kafka UI..."
    docker-compose down
    echo_info "Kafka UI stopped"
}

# Stop all Kafka processes
stop_all_kafka() {
    echo_info "Stopping all Kafka processes..."
    pkill -f kafka.Kafka || echo_warn "No Kafka processes found"
    sleep 2
    echo_info "All Kafka processes stopped"
}

# Clean up Kafka data directories
cleanup_kafka_data() {
    echo_warn "This will delete all Kafka data!"
    read -p "Are you sure? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        echo_info "Cleaning up Kafka data directories..."
        rm -rf /tmp/kraft-controller-logs
        rm -rf /tmp/kraft-broker1-logs
        rm -rf /tmp/kraft-broker2-logs
        rm -f "$CLUSTER_ID_FILE"
        echo_info "Kafka data cleaned up"
    else
        echo_info "Cleanup cancelled"
    fi
}

# Check Kafka cluster status
check_cluster_status() {
    echo_info "Checking Kafka cluster status..."
    
    # Check processes
    echo ""
    echo "=== Kafka Processes ==="
    if ps aux | grep kafka.Kafka | grep -v grep > /dev/null; then
        ps aux | grep kafka.Kafka | grep -v grep
    else
        echo_warn "No Kafka processes running"
    fi
    
    # Check ports
    echo ""
    echo "=== Network Listeners ==="
    netstat -tlnp 2>/dev/null | grep -E ":(9092|9093|9094)" || echo_warn "No Kafka ports listening"
    
    # Check topics (if broker is running)
    echo ""
    echo "=== Topics ==="
    if ps aux | grep broker1.properties | grep -v grep > /dev/null; then
        "$KAFKA_HOME/bin/kafka-topics.sh" --list --bootstrap-server localhost:9092 2>/dev/null || echo_warn "Cannot connect to broker"
    else
        echo_warn "Broker not running"
    fi
}

# View logs
view_logs() {
    local component="$1"
    
    case "$component" in
        controller)
            tail -f "$KAFKA_HOME/logs/controller.log"
            ;;
        broker1)
            tail -f "$KAFKA_HOME/logs/broker1.log"
            ;;
        broker2)
            tail -f "$KAFKA_HOME/logs/broker2.log"
            ;;
        *)
            echo_error "Unknown component: $component"
            echo "Usage: $0 logs [controller|broker1|broker2]"
            exit 1
            ;;
    esac
}

# Main menu
show_menu() {
    cat << EOF

Kafka Linux Install - Helper Script
====================================
1. Start Kafka UI
2. Stop Kafka UI
3. Stop all Kafka processes
4. Check cluster status
5. View controller logs
6. View broker1 logs
7. View broker2 logs
8. Cleanup Kafka data
9. Exit

EOF
    read -p "Choose an option: " choice
    
    case "$choice" in
        1) start_kafka_ui ;;
        2) stop_kafka_ui ;;
        3) stop_all_kafka ;;
        4) check_cluster_status ;;
        5) view_logs controller ;;
        6) view_logs broker1 ;;
        7) view_logs broker2 ;;
        8) cleanup_kafka_data ;;
        9) exit 0 ;;
        *) echo_error "Invalid option" ;;
    esac
}

# Parse command line arguments
if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
    done
else
    # Command mode
    case "$1" in
        start-ui)
            start_kafka_ui
            ;;
        stop-ui)
            stop_kafka_ui
            ;;
        stop-all)
            stop_all_kafka
            ;;
        status)
            check_cluster_status
            ;;
        logs)
            if [ -z "$2" ]; then
                echo_error "Specify component: controller, broker1, or broker2"
                exit 1
            fi
            view_logs "$2"
            ;;
        cleanup)
            cleanup_kafka_data
            ;;
        *)
            echo "Usage: $0 [start-ui|stop-ui|stop-all|status|logs <component>|cleanup]"
            echo "Or run without arguments for interactive mode"
            exit 1
            ;;
    esac
fi
