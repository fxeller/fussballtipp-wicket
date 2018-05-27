package de.delmak.fussballtipp;

import de.delmak.fussballtipp.persistence.Betgroup;
import de.delmak.fussballtipp.persistence.Role;
import de.delmak.fussballtipp.persistence.User;
import de.delmak.fussballtipp.persistence.UserBetgroup;
import de.delmak.fussballtipp.persistence.UserRole;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import org.apache.wicket.authroles.authorization.strategies.role.annotations.AuthorizeInstantiation;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.CheckBox;
import org.apache.wicket.markup.html.form.CheckBoxMultipleChoice;
import org.apache.wicket.markup.html.form.ChoiceRenderer;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.form.TextField;
import org.apache.wicket.markup.html.link.BookmarkablePageLink;
import org.apache.wicket.markup.html.link.ExternalLink;
import org.apache.wicket.markup.html.link.Link;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.markup.html.panel.FeedbackPanel;
import org.apache.wicket.model.CompoundPropertyModel;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.request.mapper.parameter.PageParameters;
import org.apache.wicket.util.string.StringValue;
import org.apache.wicket.validation.validator.EmailAddressValidator;
import org.apache.wicket.validation.validator.StringValidator;
import org.hibernate.Hibernate;

@AuthorizeInstantiation({"ADMIN","TIPPADMIN"})
public class UserEntryFeedAministration extends BasePage
{
	private Integer betgroupId;

	public final Integer getBetgroupId()
	{
		return betgroupId;
	}

	public final void setBetgroupId(Integer betgroupId)
	{
		this.betgroupId = betgroupId;
	}

        public UserEntryFeedAministration(final PageParameters parameters)
	{
		List<Betgroup> betgroups = null;
		betgroups = UserBetgroup.getBetgroupsByUserId(UserSession.get().getCurrentUser().getUserId());

		StringValue paramBetgroupId = parameters.get("betgroupid");
		if (paramBetgroupId.isEmpty() == false)
		{
			setBetgroupId(paramBetgroupId.toInt());
		}
		else
		{
			setBetgroupId(betgroups.get(0).getBetgroupId());
		}

		ListView rptBetgroupFilter = new ListView<Betgroup>("rptBetgroupFilter", betgroups)
			{

				@Override
				protected void populateItem(ListItem item)
				{
					Betgroup betgroup = (Betgroup) item.getModelObject();

					PageParameters params = new PageParameters();
					params.add("betgroupid", betgroup.getBetgroupId());
					
					BookmarkablePageLink lnkBetgroupFilter = new BookmarkablePageLink("lnkBetgroupFilter", UserEntryFeedAministration.class, params);
					lnkBetgroupFilter.add(new Label("lblBetgroupFilter", betgroup.getDescription()));
					lnkBetgroupFilter.add(new BookmarkablePageLinkBehaviour());
					item.add(lnkBetgroupFilter);
				}
			};
		
		rptBetgroupFilter.setVisible(betgroups.size() > 1);
		add(rptBetgroupFilter);

		List users = UserBetgroup.getUsersByBetgroupId_2(getBetgroupId());
                
		ListView rptData = new ListView<User>("rptData", users)
			{

				@Override
				protected void populateItem(ListItem item)
				{
					User user = (User)item.getModelObject();
					
					item.add(new Label("fldLastname", new PropertyModel(item.getModel(), "lastname")));
					item.add(new Label("fldFirstname", new PropertyModel(item.getModel(), "firstname")));
					item.add(new Label("fldHaspaidentryfeetext", new PropertyModel(item.getModel(), "haspaidentryfeetext")));
					
					Link lnkSwitchPaidState = new Link("lnkSwitchPaidState", item.getModel()) {

						@Override
						public void onClick()
						{
							User user = (User) getModelObject();
							
							user.setHaspaidentryfee(!user.isHaspaidentryfee());
							
							User.modify(user);

							setResponsePage(UserEntryFeedAministration.class);
						}
					};
					item.add(lnkSwitchPaidState);
                                }
			};
		
		add(rptData);
		
		FeedbackPanel pnlFeedback = new FeedbackPanel("pnlFeedback");
		add(pnlFeedback);
	}
}
