module ApplicationHelper
  def table_action_link(label, path, icon:)
    link_to path, class: "table-action", title: label, aria: { label: label } do
      render "shared/portal_icon", name: icon
    end
  end

  def format_date(date)
    date&.strftime("%d-%m-%Y") || "—"
  end

  def format_month(date)
    date&.strftime("%B %Y") || "—"
  end

  def workspace_label(user)
    user.authority? ? "Authority" : "Developer"
  end

  def portal_home_path(user)
    user.authority? ? authority_root_path : developer_root_path
  end

  def profile_initials(user)
    user.name.to_s.split.filter_map { |part| part[0] }.first(2).join.upcase.presence || "U"
  end

  def profile_avatar(user, class_name: "h-9 w-9")
    if user.avatar.attached?
      image_tag user.avatar,
        alt: "#{user.name} profile photo",
        class: "#{class_name} rounded-full object-cover ring-1 ring-slate-200",
        loading: "lazy"
    else
      content_tag :span,
        profile_initials(user),
        class: "#{class_name} avatar-fallback"
    end
  end

  def status_classes(status)
    {
      "draft" => "bg-slate-100 text-slate-700",
      "under_review" => "bg-amber-100 text-amber-800",
      "reverted" => "bg-red-100 text-red-700",
      "approved" => "bg-emerald-100 text-emerald-700"
    }.fetch(status.to_s, "bg-slate-100 text-slate-700")
  end
end
